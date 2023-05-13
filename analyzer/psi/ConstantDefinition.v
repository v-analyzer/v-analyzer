module psi

pub struct ConstantDefinition {
	PsiElementImpl
}

fn (c &ConstantDefinition) identifier() ?PsiElement {
	return c.find_child_by_type(.identifier)
}

pub fn (c ConstantDefinition) name() string {
	identifier := c.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (c ConstantDefinition) doc_comment() string {
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
	return c.last_child()
}
