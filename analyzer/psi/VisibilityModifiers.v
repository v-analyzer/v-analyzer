module psi

pub struct VisibilityModifiers {
	PsiElementImpl
}

pub fn (n VisibilityModifiers) is_public() bool {
	children := n.children()
	return children.any(it.get_text() == 'pub')
}

fn (n &VisibilityModifiers) stub() {}
