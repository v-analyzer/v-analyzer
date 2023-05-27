module psi

pub struct InterfaceMethodDeclaration {
	PsiElementImpl
}

pub fn (m InterfaceMethodDeclaration) identifier() ?PsiElement {
	return m.find_child_by_type(.identifier) or { return none }
}

pub fn (m InterfaceMethodDeclaration) identifier_text_range() TextRange {
	if m.stub_id != non_stubbed_element {
		if stub := m.stubs_list.get_stub(m.stub_id) {
			return stub.text_range
		}
	}

	identifier := m.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (m InterfaceMethodDeclaration) signature() ?&Signature {
	signature := m.find_child_by_type_or_stub(.signature) or { return none }
	if signature is Signature {
		return signature
	}
	return none
}

pub fn (m InterfaceMethodDeclaration) name() string {
	if m.stub_id != non_stubbed_element {
		if stub := m.stubs_list.get_stub(m.stub_id) {
			return stub.name
		}
	}

	identifier := m.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (m &InterfaceMethodDeclaration) owner() ?PsiElement {
	if struct_ := m.parent_of_type(.struct_declaration) {
		return struct_
	}
	return m.parent_of_type(.interface_declaration)
}

pub fn (m &InterfaceMethodDeclaration) scope() ?&StructFieldScope {
	element := m.sibling_of_type_backward(.struct_field_scope)?
	if element is StructFieldScope {
		return element
	}
	return none
}

pub fn (m InterfaceMethodDeclaration) doc_comment() string {
	if m.stub_id != non_stubbed_element {
		if stub := m.stubs_list.get_stub(m.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(m)
}

pub fn (_ InterfaceMethodDeclaration) stub() {}
