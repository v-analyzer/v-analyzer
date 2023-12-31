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

pub struct EnumDeclaration {
	PsiElementImpl
}

pub fn (e &EnumDeclaration) is_public() bool {
	modifiers := e.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (e &EnumDeclaration) get_type() types.Type {
	module_fqn := stubs_index.get_module_qualified_name(e.containing_file.path)
	return types.new_enum_type(e.name(), module_fqn)
}

pub fn (e EnumDeclaration) identifier() ?PsiElement {
	return e.find_child_by_type(.identifier)
}

pub fn (e EnumDeclaration) identifier_text_range() TextRange {
	if stub := e.get_stub() {
		return stub.identifier_text_range
	}

	identifier := e.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (e EnumDeclaration) name() string {
	if stub := e.get_stub() {
		return stub.name
	}

	identifier := e.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (e EnumDeclaration) doc_comment() string {
	if stub := e.get_stub() {
		return stub.comment
	}
	return extract_doc_comment(e)
}

pub fn (e EnumDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := e.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (e EnumDeclaration) fields() []PsiElement {
	if stub := e.get_stub() {
		return stub.get_children_by_type(.enum_field_definition).get_psi()
	}

	return e.find_children_by_type(.enum_field_definition)
}

pub fn (s &EnumDeclaration) attributes() []PsiElement {
	attributes := s.find_child_by_type_or_stub(.attributes) or { return [] }
	if attributes is Attributes {
		return attributes.attributes()
	}

	return []
}

pub fn (e EnumDeclaration) is_flag() bool {
	attributes := e.attributes()

	for attr in attributes {
		if attr is Attribute {
			keys := attr.keys()
			return 'flag' in keys
		}
	}

	return false
}

pub fn (_ EnumDeclaration) stub() {}
