module analyzer

import analyzer.psi

pub struct Analyzer {
pub mut:
	indexer    &Indexer
	stub_index psi.StubIndex
}

pub fn new() &Analyzer {
	indexer := new_indexer()
	return &Analyzer{
		indexer: indexer
	}
}

pub fn (mut a Analyzer) setup_stub_indexes() {
	mut res := []psi.StubIndexSink{cap: a.indexer.roots.len * 10}
	for root in a.indexer.roots {
		res << root.index.per_file.get_sinks()
	}

	a.stub_index = psi.new_stubs_index(res)
	stubs_index = a.stub_index
}
