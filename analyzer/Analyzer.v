module analyzer

import analyzer.indexer
import lsp

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
