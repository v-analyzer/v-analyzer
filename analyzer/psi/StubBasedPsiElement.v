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
module psi

// StubIndexKey describes the various types of indexes that are built on `index.StubTree`.
// These indexes allow us to quickly find the desired definitions by name in all indexed files,
// including the standard library and third-party libraries outside the project.
pub enum StubIndexKey as u8 {
	functions
	methods
	static_methods
	structs
	interfaces
	constants
	type_aliases
	enums
	attributes
	global_variables
	methods_fingerprint
	fields_fingerprint
	interface_methods_fingerprint
	interface_fields_fingerprint
	modules_fingerprint
	// See count_index_keys
}

// IndexSink describes the index creator interface.
// The `occurrence()` method is called for every stub in the file.
// See `StubbedElementType.index_stub()` for an example of calling this method.
//
// The `key` parameter is the index type for which the entry is to be created.
// The `value` parameter is the string that will be used as the value in the index.
// For example, for the `functions` index, this would be the name of the function.
pub interface IndexSink {
mut:
	occurrence(key StubIndexKey, value string)
}

// StubBasedPsiElement describes a marker interface for PSI elements,
// from which `index.StubTree` will be built, on which stub indexes will be built.
//
// PSI elements that implement this interface can be created from
// both ASTs and stubs (`psi.StubBase`).
// This allows them to be processed uniformly when resolving names and other
// processing, since there is no difference whether we are processing a real
// AST tree or a tree of stubs from memory.
pub interface StubBasedPsiElement {
	stub() // marker method
}
