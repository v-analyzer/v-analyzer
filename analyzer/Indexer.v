module analyzer

import time
import analyzer.index

// IndexingRootsStatus описывает статус индексации всех рутов.
pub enum IndexingRootsStatus {
	all_indexed
	needs_ensure_indexed // когда хотя бы один из индексов был взят из кеша
}

// Indexer инкапсулирует в себе логику индексации проекта
// и предоставляет интерфейс для работы с индексом.
pub struct Indexer {
pub mut:
	roots []index.IndexingRoot
}

pub fn new_indexer() &Indexer {
	return &Indexer{}
}

pub fn (mut i Indexer) add_indexing_root(root string, kind index.IndexingRootKind) {
	println('Adding indexing root ${root}')
	i.roots << index.new_indexing_root(root, kind)
}

pub fn (mut i Indexer) index() IndexingRootsStatus {
	now := time.now()
	println('Indexing ${i.roots.len} roots')

	mut need_ensure_indexed := false

	for mut indexing_root in i.roots {
		status := indexing_root.index()
		if status == .from_cache {
			// Если хотя бы один из индексов был взят из
			// кеша, то нужно убедиться, что все индексы
			// актуальны.
			need_ensure_indexed = true
		}
	}

	println('Indexing all roots took ${time.since(now)}')

	return if need_ensure_indexed {
		.needs_ensure_indexed
	} else {
		.all_indexed
	}
}

pub fn (mut i Indexer) ensure_indexed() {
	now := time.now()
	println('Ensure indexed of ${i.roots.len} roots')

	for mut indexing_root in i.roots {
		indexing_root.ensure_indexed()
	}

	println('Ensure indexed of all roots took ${time.since(now)}')
}

pub fn (mut i Indexer) save_indexes() ! {
	for mut indexing_root in i.roots {
		indexing_root.save_index() or {
			println('Failed to save index: ${err}')
			return err
		}
	}
}

pub fn (mut i Indexer) mark_as_dirty(filepath string) {
	for mut indexing_root in i.roots {
		indexing_root.mark_as_dirty(filepath)
	}
}
