module analyzer

import analyzer.indexer
import lsp
import json
import os
import time

pub struct Analyzer {
mut:
	index indexer.Indexer
}

pub fn new() &Analyzer {
	return &Analyzer{
		index: indexer.new()
	}
}

pub fn (mut a Analyzer) index(root lsp.DocumentUri) {
	a.index.index(root)

	data := json.encode(a.index.index)
	os.write_file('index.json', data) or { println('Failed to write index.json') }
}

pub fn (mut a Analyzer) load_index(path string) {
	now := time.now()
	data := os.read_file(path) or {
		println('Failed to read index.json')
		return
	}
	res := json.decode(indexer.PerFileCache, data) or {
		println('Failed to decode index.json')
		return
	}
	a.index.index = &res
	println('Loaded index in ${time.since(now)}')
}

pub fn (mut a Analyzer) find_function(name string) ?indexer.FunctionCache {
	index := a.index.index
	for _, datum in index.data {
		for func in datum.functions {
			if func.name == name {
				return func
			}
		}
	}
	return none
}
