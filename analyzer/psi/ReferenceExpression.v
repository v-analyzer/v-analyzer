module psi

pub struct ReferenceExpression {
	PsiElementImpl
}

pub fn (r ReferenceExpression) identifier() ?PsiElement {
	return r.first_child()
}

pub fn (r ReferenceExpression) name() string {
	identifier := r.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (r ReferenceExpression) qualifier() ?PsiElement {
	parent := r.parent() or { return none }

	if parent is SelectorExpression {
		left := parent.left()
		if left.is_equal(r) {
			return none
		}

		return left
	}

	return none
}
