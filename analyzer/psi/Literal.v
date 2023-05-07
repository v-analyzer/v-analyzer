module psi

import analyzer.psi.types

pub struct Literal {
	PsiElementImpl
}

fn (n &Literal) expr() {}

fn (n &Literal) get_type() types.Type {
	child := n.first_child() or { return types.unknown_type }
	if child.node.type_name == .interpreted_string_literal {
		return types.new_primitive_type('string')
	}

	return types.new_primitive_type('int')
}
