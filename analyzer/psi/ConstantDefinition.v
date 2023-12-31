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

import analyzer.parser
import analyzer.psi.types

pub struct ConstantDefinition {
	PsiElementImpl
}

pub fn (c &ConstantDefinition) is_public() bool {
	modifiers := c.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (c &ConstantDefinition) get_type() types.Type {
	expr := c.expression() or { return types.unknown_type }
	return infer_type(expr)
}

fn (c &ConstantDefinition) identifier() ?PsiElement {
	return c.find_child_by_type(.identifier)
}

pub fn (c ConstantDefinition) identifier_text_range() TextRange {
	if stub := c.get_stub() {
		return stub.identifier_text_range
	}

	identifier := c.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (c ConstantDefinition) name() string {
	if stub := c.get_stub() {
		return stub.name
	}

	identifier := c.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (c ConstantDefinition) doc_comment() string {
	if stub := c.get_stub() {
		return stub.comment
	}
	parent := c.parent() or { return '' }
	return extract_doc_comment(parent)
}

pub fn (c ConstantDefinition) visibility_modifiers() ?&VisibilityModifiers {
	if c.stub_based() {
		modifiers := c.prev_sibling_of_type(.visibility_modifiers)?
		if modifiers is VisibilityModifiers {
			return modifiers
		}
		return none
	}

	decl := c.parent()?
	modifiers := decl.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (c &ConstantDefinition) expression() ?PsiElement {
	if stub := c.get_stub() {
		// pretty hacky but it works
		res := parser.parse_code(stub.additional)
		root := res.tree.root_node()
		first_child := root.first_child()?
		next_first_child := first_child.first_child()?
		file := new_psi_file(c.containing_file.path, res.tree, res.source_text)
		return create_element(AstNode(next_first_child), file)
	}
	return c.last_child()
}

pub fn (_ ConstantDefinition) stub() {}
