module psi

pub struct CallExpression {
	PsiElementImpl
}

pub fn (c CallExpression) resolve() ?PsiElement {
	ref_expr := c.find_child_by_type(.reference_expression) or { return none }

	if ref_expr is ReferenceExpression {
		resolved := ref_expr.resolve() or { return none }
		return resolved
	}

	return none
}

pub fn (c CallExpression) parameter_index_on_offset(offset u32) int {
	argument_list := c.find_child_by_type(.argument_list) or { return -1 }
	commas := argument_list.children().filter(it.get_text() == ',')
	count_commas_before := commas.filter(it.node.start_byte() < offset).len
	return count_commas_before
}
