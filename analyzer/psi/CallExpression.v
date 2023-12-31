// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module psi

import analyzer.psi.types

pub struct CallExpression {
	PsiElementImpl
}

fn (c &CallExpression) get_type() types.Type {
	return infer_type(c)
}

fn (c &CallExpression) caller_type() types.Type {
	ref_expression := c.ref_expression() or { return types.unknown_type }
	if qualifier := ref_expression.qualifier() {
		return infer_type(qualifier)
	}
	return types.unknown_type
}

pub fn (c CallExpression) expression() ?PsiElement {
	return c.first_child()
}

pub fn (c CallExpression) ref_expression() ?ReferenceExpressionBase {
	if selector_expr := c.find_child_by_type(.selector_expression) {
		if selector_expr is ReferenceExpressionBase {
			return selector_expr
		}
	} else if ref_expr := c.find_child_by_type(.reference_expression) {
		if ref_expr is ReferenceExpressionBase {
			return ref_expr
		}
	}

	return none
}

pub fn (c CallExpression) resolve() ?PsiElement {
	expr := c.ref_expression()?

	if expr is ReferenceExpressionBase {
		resolved := expr.resolve()?
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
	return c.has_child_of_type(.special_argument_list)
}

pub fn (c &CallExpression) get_json_decode_type() types.Type {
	list := c.find_child_by_type(.special_argument_list) or { return types.unknown_type }
	typ := list.find_child_by_type(.plain_type) or { return types.unknown_type }
	mut visited := map[string]types.Type{}
	return TypeInferer{}.convert_type(typ, mut visited)
}

fn (c &CallExpression) type_arguments() ?&GenericTypeArguments {
	type_parameters := c.find_child_by_name('type_parameters')?
	if type_parameters is GenericTypeArguments {
		return type_parameters
	}
	return none
}
