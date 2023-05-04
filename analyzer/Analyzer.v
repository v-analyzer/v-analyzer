module analyzer

import analyzer.indexer
import lsp
import os
import time

pub struct Analyzer {
pub mut:
	index    &indexer.Indexer
	resolver Resolver
}

pub fn new() &Analyzer {
	index := indexer.new()
	return &Analyzer{
		index: index
		resolver: Resolver{
			index: index
		}
	}
}

pub fn (mut a Analyzer) index(root lsp.DocumentUri) {
	a.index.index(root)

	data := a.index.index.encode()
	os.write_file('index.json', data) or { println('Failed to write index.json') }
}

pub fn (mut a Analyzer) load_index(path string) ! {
	now := time.now()
	data := os.read_file(path) or {
		println('Failed to read ${path}')
		return
	}
	a.index.index.decode(data) or {
		if err is indexer.IndexVersionMismatchError {
			println('Index version mismatch')
		} else {
			println('Error load index ${path}: ${err}')
		}
		return indexer.NeedReindexedError{}
	}
	println('Loaded index in ${time.since(now)}')
}
