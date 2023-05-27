module psi

pub struct ModuleClause {
	PsiElementImpl
}

fn (_ &ModuleClause) stub() {}

pub fn (_ &ModuleClause) is_public() bool {
	return true
}

fn (n &ModuleClause) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &ModuleClause) identifier_text_range() TextRange {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.text_range
		}
	}

	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n ModuleClause) name() string {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.name
		}
	}

	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}
