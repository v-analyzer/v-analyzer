module psi

import analyzer.psi.types

pub struct TypeSelectorExpression {
	PsiElementImpl
}

fn (n &TypeSelectorExpression) get_type() types.Type {
	right := n.right()
	if right is ReferenceExpressionBase {
		resolved := right.resolve() or { return types.unknown_type }
		if resolved is PsiTypedElement {
			return resolved.get_type()
		}
	}

	return types.unknown_type
}

pub fn (n TypeSelectorExpression) left() PsiElement {
	return n.first_child() or { panic('') }
}

pub fn (n TypeSelectorExpression) right() PsiElement {
	return n.last_child() or { panic('') }
}
