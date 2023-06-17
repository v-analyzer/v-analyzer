[translated]
module psi

import time
import os
import loglib

__global stubs_index = StubIndex{}

const (
	count_index_keys               = 13 // StubIndexKey
	count_stub_index_location_keys = 5 // StubIndexLocationKind
)

// StubIndexLocationKind describes the type of index.
// same as `IndexingRootKind`
pub enum StubIndexLocationKind {
	standard_library
	modules
	stubs
	workspace
}

pub struct StubIndex {
pub mut:
	sinks []StubIndexSink
	// module_to_files describes how to map the full name of a module to a list
	// of files that this module contains.
	module_to_files map[string][]StubIndexSink
	// file_to_module describes the mapping of a file path to the full name
	// of the module that this file belongs to.
	file_to_module map[string]string
	// data defines the index data that allows you to get the description of the element
	// in 2 accesses to the array elements and one lookup by key.
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

	loglib.with_duration(watch.elapsed()).log_one(.info, 'Build stubs index')
	return index
}

pub fn (mut s StubIndex) sub_indexes_from_sink(sink StubIndexSink) {
	s.module_to_files[sink.stub_list.module_fqn] << sink
	s.file_to_module[sink.stub_list.path] = sink.stub_list.module_fqn
}

pub fn (mut s StubIndex) update_index_from_sink(sink StubIndexSink) {
	element_type := StubbedElementType{}
	s.sub_indexes_from_sink(sink)

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

			mut data_by_name := mp[name]
			data_by_name.stubs << stubs_result
			data_by_name.psis << psi_result
			mp[name] = data_by_name
		}
		s.data[kind][index_id] = mp.move()
	}
}

pub fn (mut s StubIndex) update_stubs_index(changed_sinks []StubIndexSink, all_sinks []StubIndexSink) {
	loglib.log_one(.info, 'Updating stubs index...')
	loglib.log_one(.info, 'Changed files: ${changed_sinks.len}')

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
			// for non workspace sinks we just update the module_to_files and file_to_module maps
			s.sub_indexes_from_sink(sink)
			continue
		}

		s.update_index_from_sink(sink)
	}
}

// get_all_elements_from returns a list of all PSI elements defined in the given index.
//
// Example:
// ```
// // gets all the elements defined in the current project
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

// get_all_elements_from_by_key returns a list of all PSI elements defined in the given index for the given key.
//
// Example:
// ```
// // gets all the functions defined in the current project
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

// get_all_declarations_from_module returns a list of all PSI elements defined in the given module.
pub fn (s &StubIndex) get_all_declarations_from_module(module_fqn string, only_types bool) []PsiElement {
	files := s.module_to_files[module_fqn] or { return []PsiElement{} }

	mut elements := []PsiElement{cap: files.len * 10}
	for sink in files {
		$for key in StubIndexKey.values {
			if key.value !in [.methods, .attributes, .methods_fingerprint, .fields_fingerprint] {
				if !only_types
					|| (only_types && key.value !in [.functions, .constants, .global_variables]) {
					elements << s.get_all_elements_from_sink_by_key(key.value, sink)
				}
			}
		}
	}
	return elements
}

pub fn (s &StubIndex) get_all_sinks_from_module(module_fqn string) []StubIndexSink {
	return s.module_to_files[module_fqn] or { return []StubIndexSink{} }
}

pub fn (s &StubIndex) get_all_sink_depends_on(module_fqn string) []StubIndexSink {
	mut sinks := []StubIndexSink{cap: 10}
	for sink in s.sinks {
		if sink.kind != .workspace {
			continue
		}

		if module_fqn in sink.imported_modules {
			sinks << sink
		}
	}
	return sinks
}

pub fn (s &StubIndex) get_sink_for_file(file string) ?StubIndexSink {
	for sink in s.sinks {
		if sink.stub_list.path == file {
			return sink
		}
	}
	return none
}

// get_elements_by_name returns the definitions of the element with the given name from the given index.
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

pub fn (s &StubIndex) get_elements_from_by_name(from StubIndexLocationKind, key StubIndexKey, name string) []PsiElement {
	mut elements := []PsiElement{cap: 5}
	data := s.data[from]
	res := data[key]
	if found := res[name] {
		elements << found.psis
	}
	return elements
}

// get_any_elements_by_name returns the definitions of the element with the given name.
pub fn (s &StubIndex) get_any_elements_by_name(name string) []PsiElement {
	mut elements := []PsiElement{cap: 5}

	$for value in StubIndexLocationKind.values {
		data := s.data[value.value]
		$for key in StubIndexKey.values {
			if key.value !in [.methods, .attributes] {
				res := data[key.value]
				if found := res[name] {
					elements << found.psis
				}
			}
		}
	}
	return elements
}

// get_module_qualified_name returns the fully qualified name of the module in which the file is defined.
pub fn (s &StubIndex) get_module_qualified_name(file string) string {
	return s.file_to_module[file] or { '' }
}

// get_module_root returns the module's root directory.
pub fn (s &StubIndex) get_module_root(module_fqn string) string {
	files := s.module_to_files[module_fqn] or { return '' }
	first := files[0] or { return '' }
	return os.dir(first.stub_list.path)
}

// get_all_modules returns all known modules.
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
mut:
	stubs []&StubBase
	psis  []PsiElement
}
