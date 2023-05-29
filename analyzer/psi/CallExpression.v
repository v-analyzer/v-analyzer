module psi

import analyzer.psi.types

pub struct CallExpression {
	PsiElementImpl
}

fn (c &CallExpression) get_type() types.Type {
	return TypeInferer{}.infer_type(c)
}

pub fn (c CallExpression) error_propagation() ?PsiElement {
	return c.find_child_by_type(.error_propagate)
}

pub fn (c CallExpression) expression() ?PsiElement {
	return c.first_child()
}

pub fn (c CallExpression) resolve() ?PsiElement {
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

pub fn (c CallExpression) parameter_index_on_offset(offset u32) int {
	argument_list := c.find_child_by_type(.argument_list) or { return -1 }
	commas := argument_list.children().filter(it.get_text() == ',')
	count_commas_before := commas.filter(it.node.start_byte() < offset).len
	return count_commas_before
}

pub fn (c CallExpression) arguments() []PsiElement {
	argument_list := c.find_child_by_type(.argument_list) or { return [] }
	arguments := argument_list.find_children_by_type(.argument)
	mut exprs := []PsiElement{cap: arguments.len}
	for argument in arguments {
		exprs << argument.first_child() or { continue }
	}
	return exprs
}

pub fn (c CallExpression) is_json_decode() bool {
	if _ := c.find_child_by_type(.special_argument_list) {
		return true
	}
	return false
}

pub fn (c &CallExpression) get_json_decode_type() types.Type {
	list := c.find_child_by_type(.special_argument_list) or { return types.unknown_type }
	typ := list.find_child_by_type(.plain_type) or { return types.unknown_type }
	return TypeInferer{}.convert_type(typ)
}
