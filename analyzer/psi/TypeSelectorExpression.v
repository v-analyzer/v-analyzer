module psi

pub struct TypeSelectorExpression {
	PsiElementImpl
}

pub fn (n TypeSelectorExpression) left() PsiElement {
	return n.first_child() or { panic('') }
}

pub fn (n TypeSelectorExpression) right() PsiElement {
	return n.last_child() or { panic('') }
}
