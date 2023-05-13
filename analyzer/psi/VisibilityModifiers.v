module psi

pub struct VisibilityModifiers {
	PsiElementImpl
}

pub fn (n MutabilityModifiers) is_public() bool {
	children := n.children()
	return children.any(it.get_text() == 'pub')
}
