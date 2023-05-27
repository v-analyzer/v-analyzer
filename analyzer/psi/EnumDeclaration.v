module psi

import analyzer.psi.types

pub struct EnumDeclaration {
	PsiElementImpl
}

pub fn (e &EnumDeclaration) get_type() types.Type {
	module_fqn := stubs_index.get_module_qualified_name(e.containing_file.path)
	return types.new_enum_type(e.name(), module_fqn)
}

pub fn (e EnumDeclaration) identifier() ?PsiElement {
	return e.find_child_by_type(.identifier)
}

pub fn (e EnumDeclaration) identifier_text_range() TextRange {
	if e.stub_id != non_stubbed_element {
		if stub := e.stubs_list.get_stub(e.stub_id) {
			return stub.text_range
		}
	}

	identifier := e.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (e EnumDeclaration) name() string {
	if e.stub_id != non_stubbed_element {
		if stub := e.stubs_list.get_stub(e.stub_id) {
			return stub.name
		}
	}

	identifier := e.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (e EnumDeclaration) doc_comment() string {
	if e.stub_id != non_stubbed_element {
		if stub := e.stubs_list.get_stub(e.stub_id) {
			return stub.comment
		}
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
	if e.stub_id != non_stubbed_element {
		if stub := e.stubs_list.get_stub(e.stub_id) {
			stubs := stub.get_children_by_type(.enum_field_definition)
			mut fields := []PsiElement{cap: stubs.len}
			for field_stub in stubs {
				fields << field_stub.get_psi() or { continue }
			}
			return fields
		}
	}

	return e.find_children_by_type(.enum_field_definition)
}

pub fn (_ EnumDeclaration) stub() {}
