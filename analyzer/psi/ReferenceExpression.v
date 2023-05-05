module psi

pub struct ReferenceExpression {
	PsiElementImpl
}

pub fn (r ReferenceExpression) identifier() ?PsiElement {
	return r.find_child_by_type(.identifier) or { return none }
}

pub fn (r ReferenceExpression) name() string {
	identifier := r.find_child_by_type(.identifier) or { return '' }
	return identifier.get_text()
}
