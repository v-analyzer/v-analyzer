module psi

pub struct ConstantDefinition {
	PsiElementImpl
}

fn (c &ConstantDefinition) identifier() ?PsiElement {
	return c.find_child_by_type(.identifier)
}

pub fn (c ConstantDefinition) identifier_text_range() TextRange {
	if c.stub_id != non_stubbed_element {
		if stub := c.stubs_list.get_stub(c.stub_id) {
			return stub.text_range
		}
	}

	identifier := c.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (c ConstantDefinition) name() string {
	if c.stub_id != non_stubbed_element {
		if stub := c.stubs_list.get_stub(c.stub_id) {
			return stub.name
		}
	}

	identifier := c.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (c ConstantDefinition) doc_comment() string {
	if c.stub_id != non_stubbed_element {
		if stub := c.stubs_list.get_stub(c.stub_id) {
			return stub.comment
		}
	}
	parent := c.parent() or { return '' }
	return extract_doc_comment(parent)
}

pub fn (c ConstantDefinition) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := c.find_child_by_type(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

pub fn (c &ConstantDefinition) expression() ?PsiElement {
	if c.stub_id != non_stubbed_element {
		return none // for now
	}
	return c.last_child()
}

pub fn (c ConstantDefinition) stub() ?&StubBase {
	return none
}
