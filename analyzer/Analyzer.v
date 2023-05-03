module analyzer

import analyzer.indexer
import lsp
import os
import time

pub struct Analyzer {
pub mut:
	index indexer.Indexer
}

pub fn new() &Analyzer {
	return &Analyzer{
		index: indexer.new()
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

pub fn (mut a Analyzer) find_function(name string) ?indexer.FunctionCache {
	index := a.index.index.data
	for _, datum in index.data {
		for func in datum.functions {
			if func.name == name {
				return func
			}
		}
	}
	return none
}

pub fn (mut a Analyzer) find_struct(name string) ?indexer.StructCache {
	index := a.index.index.data
	for _, datum in index.data {
		for struct_ in datum.structs {
			if struct_.name == name {
				return struct_
			}
		}
	}
	return none
}
