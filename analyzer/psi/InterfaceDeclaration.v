module psi

import analyzer.psi.types

pub struct InterfaceDeclaration {
	PsiElementImpl
}

pub fn (s &InterfaceDeclaration) generic_parameters() ?&GenericParameters {
	generic_parameters := s.find_child_by_type_or_stub(.generic_parameters) or { return none }
	if generic_parameters is GenericParameters {
		return generic_parameters
	}
	return none
}

pub fn (s &InterfaceDeclaration) is_public() bool {
	modifiers := s.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (s &InterfaceDeclaration) module_name() string {
	return stubs_index.get_module_qualified_name(s.containing_file.path)
}

pub fn (s &InterfaceDeclaration) get_type() types.Type {
	return types.new_interface_type(s.name(), s.module_name())
}

pub fn (s &InterfaceDeclaration) attributes() []PsiElement {
	attributes := s.find_child_by_type(.attributes) or { return [] }
	if attributes is Attributes {
		return attributes.attributes()
	}

	return []
}

pub fn (s InterfaceDeclaration) identifier() ?PsiElement {
	return s.find_child_by_type(.identifier)
}

pub fn (s InterfaceDeclaration) identifier_text_range() TextRange {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.text_range
		}
	}

	identifier := s.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (s InterfaceDeclaration) name() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.name
		}
	}

	identifier := s.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (s InterfaceDeclaration) doc_comment() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(s)
}

pub fn (s InterfaceDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := s.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (s InterfaceDeclaration) fields() []PsiElement {
	return s.find_children_by_type_or_stub(.struct_field_declaration)
}

pub fn (s InterfaceDeclaration) methods() []PsiElement {
	return s.find_children_by_type_or_stub(.interface_method_definition)
}

pub fn (_ InterfaceDeclaration) stub() {}
