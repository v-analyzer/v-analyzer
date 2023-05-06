module psi

import analyzer.psi.types

pub struct ReferenceExpression {
	PsiElementImpl
}

// marker method for Expression
fn (r &ReferenceExpression) expr() {}

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

pub fn (r ReferenceExpression) reference() PsiReference {
	return new_reference(r.containing_file, r, false)
}

pub fn (r ReferenceExpression) resolve_local() ?PsiElement {
	return r.reference().resolve_local()
}

pub fn (r ReferenceExpression) get_type() types.Type {
	return types.new_unknown_type()
}
