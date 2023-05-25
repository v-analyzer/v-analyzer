module psi

pub struct UnsafeExpression {
	PsiElementImpl
}

pub fn (n UnsafeExpression) last_expression() ?PsiElement {
	block := n.find_child_by_type(.block)?
	statements := block.find_children_by_type(.simple_statement)
	if statements.len == 0 {
		return none
	}
	last_statement := statements.last()
	return last_statement.first_child()
}
