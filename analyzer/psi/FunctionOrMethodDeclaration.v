module psi

pub struct FunctionOrMethodDeclaration {
	PsiElementImpl
}

pub fn (f FunctionOrMethodDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier) or { return none }
}

pub fn (f FunctionOrMethodDeclaration) identifier_text_range() TextRange {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.text_range
		}
	}

	identifier := f.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (f FunctionOrMethodDeclaration) signature() ?&Signature {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			signature_stubs := stub.get_children_by_type(.signature)
			if signature_stubs.len > 0 {
				psi := signature_stubs.first().get_psi() or { return none }
				if psi is Signature {
					return psi
				}
			}
			return none
		}
	}

	signature := f.find_child_by_type(.signature) or { return none }
	if signature is Signature {
		return signature
	}
	return none
}

pub fn (f FunctionOrMethodDeclaration) name() string {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.name
		}
	}

	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f FunctionOrMethodDeclaration) doc_comment() string {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(f)
}

pub fn (f FunctionOrMethodDeclaration) receiver() ?&Receiver {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			receiver_stubs := stub.get_children_by_type(.receiver)
			if receiver_stubs.len > 0 {
				psi := receiver_stubs.first().get_psi() or { return none }
				if psi is Receiver {
					return psi
				}
			}
			return none
		}
	}

	element := f.find_child_by_type(.receiver) or { return none }
	if element is Receiver {
		return element
	}
	return none
}

pub fn (f FunctionOrMethodDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := f.find_child_by_type(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (_ FunctionOrMethodDeclaration) stub() {}
