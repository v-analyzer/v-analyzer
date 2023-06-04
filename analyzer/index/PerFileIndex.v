module index

import analyzer.psi

// PerFileIndex describes the cache of a group of files in the index.
pub struct PerFileIndex {
pub mut:
	data map[string]FileIndex
}

pub fn (p &PerFileIndex) get_sinks() []psi.StubIndexSink {
	mut res := []psi.StubIndexSink{cap: p.data.len}
	for _, cache in p.data {
		if !isnil(cache.sink) {
			res << *cache.sink
		}
	}
	return res
}
