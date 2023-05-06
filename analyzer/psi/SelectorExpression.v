module psi

pub struct SelectorExpression {
	PsiElementImpl
}

pub fn (n SelectorExpression) left() PsiElement {
	return n.first_child() or { panic('') }
}

pub fn (n SelectorExpression) right() PsiElement {
	return n.last_child() or { panic('') }
}
