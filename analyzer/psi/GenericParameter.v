module psi

[heap]
pub struct GenericParameter {
	PsiElementImpl
}

pub fn (n &GenericParameter) identifier_text_range() TextRange {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.text_range
		}
	}

	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n &GenericParameter) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &GenericParameter) name() string {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.name
		}
	}

	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (n &GenericParameter) is_public() bool {
	return true
}

fn (n &GenericParameter) stub() {}
