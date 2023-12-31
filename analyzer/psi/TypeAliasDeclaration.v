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

pub struct TypeAliasDeclaration {
	PsiElementImpl
}

pub fn (a &TypeAliasDeclaration) get_type() types.Type {
	return types.new_interface_type(a.name(), a.module_name())
}

pub fn (a &TypeAliasDeclaration) generic_parameters() ?&GenericParameters {
	generic_parameters := a.find_child_by_type_or_stub(.generic_parameters)?
	if generic_parameters is GenericParameters {
		return generic_parameters
	}
	return none
}

pub fn (a &TypeAliasDeclaration) is_public() bool {
	modifiers := a.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (a &TypeAliasDeclaration) module_name() string {
	return stubs_index.get_module_qualified_name(a.containing_file.path)
}

pub fn (a TypeAliasDeclaration) doc_comment() string {
	if stub := a.get_stub() {
		return stub.comment
	}
	return extract_doc_comment(a)
}

pub fn (a &TypeAliasDeclaration) types() []PlainType {
	inner_types := a.find_children_by_type_or_stub(.plain_type)
	mut result := []PlainType{cap: inner_types.len}
	for type_ in inner_types {
		if type_ is PlainType {
			result << type_
		}
	}
	return result
}

pub fn (a TypeAliasDeclaration) identifier() ?PsiElement {
	return a.find_child_by_type(.identifier)
}

pub fn (a &TypeAliasDeclaration) identifier_text_range() TextRange {
	if stub := a.get_stub() {
		return stub.identifier_text_range
	}

	identifier := a.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (a TypeAliasDeclaration) name() string {
	if stub := a.get_stub() {
		return stub.name
	}

	identifier := a.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (a TypeAliasDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := a.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

fn (_ &TypeAliasDeclaration) stub() {}
