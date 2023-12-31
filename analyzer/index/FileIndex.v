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

// FileIndex describes the cache of a single file.
// By splitting the cache into files, we can index files in parallel
// without the need for synchronization.
@[heap]
pub struct FileIndex {
pub mut:
	kind IndexingRootKind // root where the file is located
	// file_last_modified stores the time the file was last modified
	//
	// Thanks to it, while checking the cache, we can understand whether the
	// file has been changed or not.
	// If the file has been modified, then we reindex the file.
	file_last_modified i64
	// stub_list is a list of all stubs in the file.
	// Storing stubs as a table makes it easy and compact to save them to disk and load them back.
	stub_list &psi.StubList = unsafe { nil }
	// sink describes the indexed stubs of the current file.
	// So, for example, by the '.functions' key, you can get the stubs of all functions defined inside the current file.
	// See also 'StubIndexKey'.
	sink &psi.StubIndexSink = unsafe { nil }
}

pub fn (f &FileIndex) path() string {
	if f.stub_list == unsafe { nil } {
		return ''
	}
	return f.stub_list.path
}
