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

pub fn (mut p PerFileIndex) rename_file(old string, new string) ?FileIndex {
	if old == new {
		return none
	}
	if mut cache := p.data[old] {
		cache.stub_list.path = new
		p.data[new] = cache
		p.data.delete(old)
		return cache
	}

	return none
}

pub fn (mut p PerFileIndex) remove_file(path string) ?FileIndex {
	if mut cache := p.data[path] {
		p.data.delete(path)
		return cache
	}

	return none
}
