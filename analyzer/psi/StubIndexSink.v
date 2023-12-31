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

@[heap]
pub struct StubIndexSink {
pub mut:
	stub_id          StubId
	stub_list        &StubList = unsafe { nil } // List of stubs in the current file for which the index is being built.
	imported_modules []string
	kind             StubIndexLocationKind
	data             map[int]map[string][]StubId
}

const non_fqn_keys = [StubIndexKey.global_variables, .methods_fingerprint, .fields_fingerprint,
	.interface_methods_fingerprint, .interface_fields_fingerprint, .methods, .static_methods,
	.attributes, .modules_fingerprint]

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	module_fqn := s.module_fqn()
	resulting_value := if module_fqn != '' && key !in psi.non_fqn_keys {
		'${module_fqn}.${value}'
	} else {
		value
	}

	s.data[int(key)][resulting_value] << s.stub_id
}

@[inline]
pub fn (s StubIndexSink) module_fqn() string {
	if s.stub_list == unsafe { nil } {
		return ''
	}
	return s.stub_list.module_fqn
}
