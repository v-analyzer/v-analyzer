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
	mut sinks := a.all_sinks()
	a.stub_index = psi.new_stubs_index(sinks)
	stubs_index = a.stub_index
}

pub fn (mut a Analyzer) update_stub_indexes_from_sinks(changed_sinks []psi.StubIndexSink) {
	all_sinks := a.all_sinks()
	stubs_index.update_stubs_index(changed_sinks, all_sinks)
}

pub fn (mut a Analyzer) update_stub_indexes(changed_files []&psi.PsiFileImpl) {
	all_sinks := a.all_sinks()
	mut changed_sinks := []psi.StubIndexSink{cap: changed_files.len}

	for root in a.indexer.roots {
		for file in changed_files {
			file_cache := root.index.per_file.data[file.path] or { continue }
			changed_sinks << file_cache.sink
		}
	}

	stubs_index.update_stubs_index(changed_sinks, all_sinks)
}

fn (mut a Analyzer) all_sinks() []psi.StubIndexSink {
	mut sinks := []psi.StubIndexSink{cap: a.indexer.roots.len * 30}
	for root in a.indexer.roots {
		sinks << root.index.per_file.get_sinks()
	}
	return sinks
}
