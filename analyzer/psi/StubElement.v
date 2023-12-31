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

// StubElement describes the interface of any stub.
pub interface StubElement {
	id() StubId
	name() string
	text() string
	receiver() string
	stub_type() StubType
	text_range() TextRange
	parent_stub() ?&StubElement
	first_child() ?&StubElement
	children_stubs() []StubElement
	get_child_by_type(typ StubType) ?StubElement
	has_child_of_type(typ StubType) bool
	get_children_by_type(typ StubType) []StubElement
	prev_sibling() ?&StubElement
	parent_of_type(typ StubType) ?StubElement
	get_psi() ?PsiElement
}

pub fn (elements []StubElement) get_psi() []PsiElement {
	mut result := []PsiElement{cap: elements.len}
	for element in elements {
		result << element.get_psi() or { continue }
	}
	return result
}

pub fn is_valid_stub(s StubElement) bool {
	if s is StubBase {
		return !isnil(s) && !isnil(s.stub_list)
	}
	return !isnil(s)
}
