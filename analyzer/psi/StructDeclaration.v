module psi

pub struct StructDeclaration {
	PsiElementImpl
}

pub fn (s StructDeclaration) identifier() ?PsiElement {
	return s.find_child_by_type(.identifier)
}

pub fn (s StructDeclaration) identifier_text_range() TextRange {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.text_range
		}
	}

	identifier := s.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (s StructDeclaration) name() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.name
		}
	}

	identifier := s.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (s StructDeclaration) doc_comment() string {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(s)
}

pub fn (s StructDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := s.find_child_by_type(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (s StructDeclaration) fields() []PsiElement {
	if s.stub_id != non_stubbed_element {
		if stub := s.stubs_list.get_stub(s.stub_id) {
			stubs := stub.get_children_by_type(.field_declaration)
			mut fields := []PsiElement{cap: stubs.len}
			for field_stub in stubs {
				fields << field_stub.get_psi() or { continue }
			}
			return fields
		}
	}

	return s.find_children_by_type(.struct_field_declaration)
}

pub fn (s StructDeclaration) stub() ?&StubBase {
	return none
}
