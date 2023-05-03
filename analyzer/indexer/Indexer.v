module indexer

import lsp
import os
import analyzer.parser

// Indexer инкапсулирует в себе логику индексации проекта
// и предоставляет интерфейс для работы с индексом.
pub struct Indexer {
pub mut:
	index &PerFileCache
}

pub fn new() Indexer {
	return Indexer{
		index: &PerFileCache{}
	}
}

pub fn (mut i Indexer) index(root lsp.DocumentUri) {
	println('Indexing root ${root}')

	path := root.path()
	os.walk(path, fn [mut i] (path string) {
		if path.ends_with('.v') && !path.ends_with('_test.v') && !path.ends_with('.js.v') {
			i.index_file(path) or { println('Error indexing ${path}: ${err}') }
		}
	})

	println('Indexing finished')
	println(i.index.data)
}

pub fn (mut i Indexer) index_file(path string) ! {
	println('Indexing ${path}')
	content := os.read_file(path)!
	res := parser.parse_code(content)
	cache := i.index.data[path]
	mut visitor := &IndexingVisitor{
		filepath: path
		cache: &cache
	}
	res.accept(mut visitor)
	i.index.data[path] = cache
}
