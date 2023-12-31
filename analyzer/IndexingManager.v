// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module analyzer

import analyzer.psi

pub struct IndexingManager {
pub mut:
	indexer    &Indexer = unsafe { nil }
	stub_index psi.StubIndex
}

pub fn IndexingManager.new() &IndexingManager {
	indexer := new_indexer()
	return &IndexingManager{
		indexer: indexer
	}
}

pub fn (mut a IndexingManager) setup_stub_indexes() {
	mut sinks := a.all_sinks()
	a.stub_index = psi.new_stubs_index(sinks)
	stubs_index = a.stub_index
}

pub fn (mut a IndexingManager) update_stub_indexes_from_sinks(changed_sinks []psi.StubIndexSink) {
	all_sinks := a.all_sinks()
	stubs_index.update_stubs_index(changed_sinks, all_sinks)
}

pub fn (mut a IndexingManager) update_stub_indexes(changed_files []&psi.PsiFile) {
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

fn (mut a IndexingManager) all_sinks() []psi.StubIndexSink {
	mut sinks := []psi.StubIndexSink{cap: a.indexer.roots.len * 30}
	for root in a.indexer.roots {
		sinks << root.index.per_file.get_sinks()
	}
	return sinks
}
