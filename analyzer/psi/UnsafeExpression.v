module psi

pub struct UnsafeExpression {
	PsiElementImpl
}

pub fn (n UnsafeExpression) block() ?&Block {
	block := n.find_child_by_type(.block)?
	if block is Block {
		return block
	}
	return none
}

pub fn (n UnsafeExpression) last_expression() ?PsiElement {
	block := n.block()?
	return block.last_expression()
}
