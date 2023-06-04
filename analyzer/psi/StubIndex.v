[translated]
module psi

import time
import os

__global stubs_index = StubIndex{}

const (
	count_index_keys               = 9 // StubIndexKey._end (TODO: replace after https://github.com/vlang/v/issues/18310)
	count_stub_index_location_keys = 5 // StubIndexLocationKind._end
)

// StubIndexLocationKind описывает тип индекса.
// same as `IndexingRootKind`
pub enum StubIndexLocationKind {
	standard_library
	modules
	stubs
	workspace
	_end
}

pub struct StubIndex {
pub mut:
	sinks []StubIndexSink
	// module_to_files описывает отображение полного имени модуля к списку файлов
	// которые этот модуль содержит.
	module_to_files map[string][]StubIndexSink
	// file_to_module описывает отображение пути к файлу к полному имени модуля
	// которому принадлежит этот файл.
	file_to_module map[string]string
	// data определяет данные индекса которые позволяют в 2 обращения к
	// элементам массива и одного lookup по ключу получить описание элемента.
	data [count_stub_index_location_keys][count_index_keys]map[string]StubResult
}

pub fn new_stubs_index(sinks []StubIndexSink) &StubIndex {
	mut index := &StubIndex{
		sinks: sinks
		module_to_files: map[string][]StubIndexSink{}
	}

	for i in 0 .. psi.count_stub_index_location_keys {
		for j in 0 .. psi.count_index_keys {
			index.data[i][j] = map[string]StubResult{}
		}
	}

	watch := time.new_stopwatch(auto_start: true)
	for sink in sinks {
		index.update_index_from_sink(sink)
	}

	println('Time to build stubs index: ${watch.elapsed()}')
	return index
}

pub fn (mut s StubIndex) update_index_from_sink(sink StubIndexSink) {
	element_type := StubbedElementType{}
	s.module_to_files[sink.stub_list.module_name] << sink
	s.file_to_module[sink.stub_list.path] = sink.stub_list.module_name

	for index_id, datum in sink.data {
		kind := sink.kind

		mut mp := s.data[kind][index_id]
		for name, ids in datum {
			mut stubs_result := []&StubBase{cap: ids.len}
			mut psi_result := []PsiElement{cap: ids.len}
			for stub_id in ids {
				stub := sink.stub_list.index_map[stub_id] or { continue }
				stubs_result << stub
				psi_result << element_type.create_psi(stub) or { continue }
			}

			mp[name] = StubResult{
				stubs: stubs_result
				psis: psi_result
			}
		}
		s.data[kind][index_id] = mp.move()
	}
}

pub fn (mut s StubIndex) update_stubs_index(changed_sinks []StubIndexSink, all_sinks []StubIndexSink) {
	println('Updating stubs index...')
	println('Changed files: ${changed_sinks.len}')

	s.sinks = all_sinks

	mut is_workspace_changes := false
	for sink in changed_sinks {
		if sink.kind == .workspace {
			is_workspace_changes = true
			break
		}
	}

	if !is_workspace_changes {
		return
	}

	s.module_to_files = map[string][]StubIndexSink{}
	s.file_to_module = map[string]string{}

	// clear all workspace index
	s.data[StubIndexLocationKind.workspace] = [psi.count_index_keys]map[string]StubResult{}
	for i in 0 .. psi.count_index_keys {
		s.data[StubIndexLocationKind.workspace][i] = map[string]StubResult{}
	}

	for sink in all_sinks {
		if sink.kind != .workspace {
			continue
		}

		s.update_index_from_sink(sink)
	}
}

// get_all_elements_from возвращает список всех PSI элементов определенных в переданном индексе.
//
// Example:
// ```
// // получает все элементы определенные в текущем проекте
// stubs_index.get_all_elements_from(.workspace)
// ```
pub fn (s &StubIndex) get_all_elements_from(kind StubIndexLocationKind) []PsiElement {
	data := s.data[kind]

	mut all_len := 0
	$for field in StubIndexKey.values {
		res := data[field.value]
		for _, stubs in res {
			all_len += stubs.psis.len
		}
	}
	mut elements := []PsiElement{cap: all_len}

	$for key in StubIndexKey.values {
		res := data[key.value]
		for _, stubs in res {
			for psi in stubs.psis {
				elements << psi
			}
		}
	}
	return elements
}

// get_all_elements_from_by_key возвращает список всех PSI элементов определенных в переданном индексе по данному
// ключу.
//
// Example:
// ```
// // получает все функции определенные в текущем проекте
// stubs_index.get_all_elements_from_by_key(.workspace, .functions)
// ```
pub fn (s &StubIndex) get_all_elements_from_by_key(from StubIndexLocationKind, key StubIndexKey) []PsiElement {
	data := s.data[from]
	mp := data[key]

	mut elements := []PsiElement{cap: mp.len}
	for _, res in mp {
		elements << res.psis
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_file(file string) []PsiElement {
	mut elements := []PsiElement{cap: 20}
	for sink in s.sinks {
		if sink.stub_list.path != file {
			continue
		}

		$for key in StubIndexKey.values {
			elements << s.get_all_elements_from_sink_by_key(key.value, sink)
		}
	}
	return elements
}

// get_all_declarations_from_module возвращает список всех PSI элементов определенных в переданном модуле.
pub fn (s &StubIndex) get_all_declarations_from_module(module_fqn string) []PsiElement {
	files := s.module_to_files[module_fqn] or { return []PsiElement{} }

	mut elements := []PsiElement{cap: files.len * 10}
	for sink in files {
		$for key in StubIndexKey.values {
			if key.value !in [.methods, .attributes] {
				elements << s.get_all_elements_from_sink_by_key(key.value, sink)
			}
		}
	}
	return elements
}

// get_elements_by_name возвращает определения элемента с переданным именем из переданного индекса.
pub fn (s &StubIndex) get_elements_by_name(key StubIndexKey, name string) []PsiElement {
	mut elements := []PsiElement{cap: 5}

	$for value in StubIndexLocationKind.values {
		data := s.data[value.value]
		res := data[key]
		if found := res[name] {
			elements << found.psis
		}
	}
	return elements
}

// get_module_qualified_name возвращает полное имя модуля в котором определен файл.
pub fn (s &StubIndex) get_module_qualified_name(file string) string {
	return s.file_to_module[file] or { '' }
}

// get_module_root возвращает корневую директорию модуля.
pub fn (s &StubIndex) get_module_root(module_fqn string) string {
	files := s.module_to_files[module_fqn] or { return '' }
	first := files[0] or { return '' }
	return os.dir(first.stub_list.path)
}

// get_all_modules возвращает все известные модули.
pub fn get_all_modules() []string {
	return stubs_index.module_to_files.keys()
}

fn (_ &StubIndex) get_all_elements_from_sink_by_key(key StubIndexKey, sink StubIndexSink) []PsiElement {
	data := sink.data[int(key)] or { return [] }

	element_type := StubbedElementType{}
	mut elements := []PsiElement{cap: data.len}
	for _, stub_ids in data {
		for stub_id in stub_ids {
			stub := sink.stub_list.index_map[stub_id] or { continue }
			elements << element_type.create_psi(stub) or { continue }
		}
	}

	return elements
}

struct StubResult {
	stubs []&StubBase
	psis  []PsiElement
}
