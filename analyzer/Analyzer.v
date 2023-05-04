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
