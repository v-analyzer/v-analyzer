module psi

import analyzer.psi.types

pub struct ReferenceExpression {
	PsiElementImpl
}

fn (r &ReferenceExpression) expr() // marker method for Expression {}

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

pub fn (r ReferenceExpression) reference(psi_file PsiFileImpl) PsiReference {
	return new_reference(psi_file, r)
}

pub fn (r ReferenceExpression) resolve_local(psi_file PsiFileImpl) ?PsiElement {
	return r.reference(psi_file).resolve_local()
}

// pub fn (r ReferenceExpression) get_type() types.Type {
//
// }
