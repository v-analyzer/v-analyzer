module analyzer

import analyzer.parser
import analyzer.indexer
import lsp

pub struct Analyzer {
	index indexer.Indexer
}

pub fn new() &Analyzer {
	return &Analyzer{}
}

pub fn (a &Analyzer) index(root lsp.DocumentUri) {
	a.index.index(root)
}

pub fn (a &Analyzer) parse(s string) {
	res := parser.parse_code(s)
	println(res)
}
