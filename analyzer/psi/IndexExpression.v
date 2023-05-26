module psi

pub struct IndexExpression {
	PsiElementImpl
}

pub fn (c IndexExpression) expression() ?PsiElement {
	return c.first_child()
}

pub fn (c IndexExpression) resolve() ?PsiElement {
	expr := if selector_expr := c.find_child_by_type(.selector_expression) {
		selector_expr as ReferenceExpressionBase
	} else if ref_expr := c.find_child_by_type(.reference_expression) {
		ref_expr as ReferenceExpressionBase
	} else {
		return none
	}

	if expr is ReferenceExpressionBase {
		resolved := expr.resolve() or { return none }
		return resolved
	}

	return none
}
