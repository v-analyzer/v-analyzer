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

import analyzer.psi.types

pub struct EmbeddedDefinition {
	PsiElementImpl
}

pub fn (n &EmbeddedDefinition) owner() ?PsiElement {
	if struct_ := n.parent_of_type(.struct_declaration) {
		return struct_
	}
	return n.parent_of_type(.interface_declaration)
}

pub fn (n &EmbeddedDefinition) identifier_text_range() TextRange {
	if stub := n.get_stub() {
		return stub.identifier_text_range
	}

	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n &EmbeddedDefinition) identifier() ?PsiElement {
	if qualified_type := n.find_child_by_type_or_stub(.qualified_type) {
		return qualified_type.last_child_or_stub()
	}
	if generic_type := n.find_child_by_type_or_stub(.generic_type) {
		return generic_type.first_child_or_stub()
	}
	if ref_expression := n.find_child_by_type_or_stub(.type_reference_expression) {
		return ref_expression.first_child_or_stub()
	}
	return none
}

pub fn (n &EmbeddedDefinition) name() string {
	if stub := n.get_stub() {
		return stub.name
	}

	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (_ &EmbeddedDefinition) is_public() bool {
	return true
}

pub fn (n &EmbeddedDefinition) get_type() types.Type {
	return infer_type(n)
}

fn (_ &EmbeddedDefinition) stub() {}
