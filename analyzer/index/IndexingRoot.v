module index

import time
import os
import analyzer.parser
import sync
import runtime
import crypto.md5
import analyzer.psi
import math

// BuiltIndexStatus описывает статус построенного индекса.
pub enum BuiltIndexStatus {
	from_cache // индекс был загружен из кэша
	from_scratch // индекс был построен с нуля
}

// IndexingRootKind описывает тип корня, который индексируется.
pub enum IndexingRootKind {
	standard_library
	modules
	stubs
	user_code
}

// IndexingRoot инкапсулирует в себе логику индексации/реиндексации
// конкретного корня файловой системы.
//
// Разделение на отдельные руты нужно, чтобы обрабатывать стандартную
// библиотеку и пользовательский код раздельно.
[noinit]
pub struct IndexingRoot {
pub:
	root string // корень, который индексируется
	kind IndexingRootKind // тип корня
pub mut:
	updated_at time.Time // время последнего обновления индекса
	index      Index     // кэш по файлам
	cache_file string    // путь к файлу с кэшем
	need_save  bool      // нужно ли сохранять кэш при следующем вызове save_index
}

// new_indexing_root создает новый IndexingRoot для переданного пути.
pub fn new_indexing_root(root string, kind IndexingRootKind) &IndexingRoot {
	cache_file := 'spavn_index_${md5.hexhash(root)}.txt'
	return &IndexingRoot{
		root: root
		kind: kind
		cache_file: cache_file
	}
}

pub fn (mut i IndexingRoot) load_index() ! {
	now := time.now()
	if !os.exists(i.cache_file) {
		println('Index for "${i.root}" not found, indexing')
		return IndexNotFoundError{}
	}

	data := os.read_bytes(i.cache_file) or {
		println('Failed to read ${i.cache_file}')
		return IndexNotFoundError{}
	}
	i.index.decode(data) or {
		if err is IndexVersionMismatchError {
			println('Index version mismatch')
		} else {
			println('Error load index ${i.cache_file}: ${err}')
		}
		return NeedReindexedError{}
	}
	println('Loaded index in ${time.since(now)}')
}

pub fn (mut i IndexingRoot) save_index() ! {
	if !i.need_save {
		return
	}
	i.need_save = false

	data := i.index.encode()
	os.write_file_array(i.cache_file, data) or {
		println('Failed to write index.json')
		return err
	}
}

// need_index возвращает true, если файл нужно проиндексировать.
//
// Мы намеренно не индексируем тестовые файлы, чтобы ускорить
// процесс индексирования и поиск по нему.
fn (mut _ IndexingRoot) need_index(path string) bool {
	if path.ends_with('/net/http/mime/db.v') {
		return false
	}
	if !path.ends_with('.v') {
		return false
	}

	return !path.ends_with('_test.v') && !path.contains('/tests/') && !path.contains('/slow_tests/')
		&& !path.contains('/.vmodules/cache/')
		&& !path.contains('/builtin/wasm/') // TODO: индексировать и эту папку
		&& !path.contains('/builtin/js/') // TODO: индексировать и эту папку
		&& !path.contains('/builtin/linux_bare/') // TODO: индексировать и эту папку
		&& !path.ends_with('.js.v')
}

pub fn (mut i IndexingRoot) index() BuiltIndexStatus {
	now := time.now()
	println('Indexing root ${i.root}')

	if _ := i.load_index() {
		println('Index loaded from cache, took ${time.since(now)}')
		return .from_cache
	}

	file_chan := chan string{cap: 1000}
	cache_chan := chan FileIndex{cap: 1000}

	spawn fn [mut i, file_chan] () {
		path := i.root
		os.walk(path, fn [mut i, file_chan] (path string) {
			if i.need_index(path) {
				file_chan <- path
			}
		})

		file_chan.close()
	}()

	spawn i.spawn_indexing_workers(cache_chan, file_chan)

	mut caches := []FileIndex{cap: 100}
	for {
		cache := <-cache_chan or { break }
		caches << cache
	}

	for cache in caches {
		i.index.per_file.data[cache.filepath] = cache
	}

	i.updated_at = time.now()
	i.need_save = true

	println('Indexing finished')
	println('Indexing took ${time.since(now)}')
	return .from_scratch
}

pub fn (mut r IndexingRoot) index_file(path string) !FileIndex {
	last_modified := os.file_last_mod_unix(path)
	content := os.read_file(path)!
	res := parser.parse_code(content)
	psi_file := psi.new_psi_file(path, res.tree, content)
	mut cache := FileIndex{
		filepath: path
		file_last_modified: last_modified
		module_name: psi_file.module_name() or { '' }
		module_fqn: r.module_qualified_name(psi_file)
		sink: &psi.StubIndexSink{}
	}
	stub_tree := build_stub_tree(psi_file)

	stub_type := psi.StubbedElementType{}
	mut stub_list := stub_tree.root.stub_list
	stub_list.module_name = cache.module_fqn
	cache.sink.module_name = cache.module_fqn

	stubs := stub_list.index_map.values()
	for stub in stubs {
		cache.sink.stub_id = stub.id
		cache.sink.stub_list = stub.stub_list
		stub_type.index_stub(stub, mut cache.sink)
	}
	cache.stub_list = stub_list

	unsafe { res.tree.free() }
	return cache
}

pub fn (mut r IndexingRoot) module_qualified_name(file &psi.PsiFileImpl) string {
	module_name := file.module_name() or { '' }
	if module_name == 'main' {
		return module_name
	}
	if module_name == 'builtin' {
		return ''
	}

	root_dirs := [r.root]

	containing_dir := os.dir(file.path)

	mut module_names := []string{}

	mut dir := containing_dir
	for dir != '' && dir !in root_dirs {
		module_names << os.file_name(dir)
		dir = os.dir(dir)
	}

	module_names.reverse_in_place()

	if module_names.len == 0 {
		return module_name
	}

	if module_names.first() == 'builtin' {
		module_names = module_names[1..]
	}

	if module_names.len != 0 && module_names.last() == module_name {
		module_names = module_names[..module_names.len - 1]
	}

	qualifier := module_names.join('.')
	if qualifier == '' {
		return module_name
	}

	return qualifier + '.' + module_name
}

pub fn (mut i IndexingRoot) spawn_indexing_workers(cache_chan chan FileIndex, file_chan chan string) {
	mut wg := sync.new_waitgroup()
	cpus := runtime.nr_cpus()
	workers := math.max(cpus - 4, 1)
	wg.add(workers)
	for j := 0; j < workers; j++ {
		spawn fn [file_chan, mut wg, mut i, cache_chan] () {
			for {
				file := <-file_chan or { break }
				cache_chan <- i.index_file(file) or { println('Error indexing ${file}: ${err}') }
			}

			wg.done()
		}()
	}

	wg.wait()
	cache_chan.close()
}

// ensure_indexed проверяет индекс на актуальность и переиндексирует
// файлы, если они были изменены после последнего индексирования.
pub fn (mut i IndexingRoot) ensure_indexed() {
	now := time.now()
	println('Ensuring indexed root ${i.root}')

	reindex_files_chan := chan string{cap: 1000}
	cache_chan := chan FileIndex{cap: 1000}

	spawn fn [reindex_files_chan, mut i] () {
		for filepath, datum in i.index.per_file.data {
			last_modified := os.file_last_mod_unix(filepath)
			if last_modified > datum.file_last_modified {
				println('File ${filepath} was modified, reindexing')
				i.index.per_file.data.delete(filepath)
				reindex_files_chan <- filepath
			}
		}

		reindex_files_chan.close()
	}()

	spawn i.spawn_indexing_workers(cache_chan, reindex_files_chan)

	mut caches := []FileIndex{cap: 100}
	for {
		cache := <-cache_chan or { break }
		caches << cache
	}

	for cache in caches {
		i.index.per_file.data[cache.filepath] = cache
	}

	if caches.len > 0 {
		i.index.updated_at = time.now()
		i.need_save = true
	}

	println('Reindexing finished')
	println('Reindexing took ${time.since(now)}')
}

pub fn (mut i IndexingRoot) mark_as_dirty(filepath string) {
	if filepath !in i.index.per_file.data {
		// файл не принадлежит этому индексу
		return
	}

	println('Marking ${filepath} as dirty')
	i.index.per_file.data.delete(filepath)
	res := i.index_file(filepath) or {
		println('Error indexing dirty ${filepath}: ${err}')
		return
	}
	i.index.per_file.data[filepath] = res
	i.index.updated_at = time.now()
	i.save_index() or { println(err) }

	println('Finished reindexing ${filepath}')
}
