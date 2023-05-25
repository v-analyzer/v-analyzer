module psi

import analyzer.psi.types

pub struct Literal {
	PsiElementImpl
}

fn (_ &Literal) expr() {}

fn (n &Literal) get_type() types.Type {
	child := n.first_child() or { return types.unknown_type }
	if child.node.type_name == .interpreted_string_literal
		|| child.node.type_name == .raw_string_literal {
		return types.string_type
	}

	if child.node.type_name == .c_string_literal {
		return types.new_pointer_type(types.new_primitive_type('u8'))
	}

	if child.node.type_name == .int_literal {
		return types.new_primitive_type('int')
	}

	if child.node.type_name == .float_literal {
		return types.new_primitive_type('f64')
	}

	if child.node.type_name == .rune_literal {
		return types.new_primitive_type('rune')
	}

	if child.node.type_name == .true_ || child.node.type_name == .false_ {
		return types.new_primitive_type('bool')
	}

	if child.node.type_name == .nil_ {
		return types.new_primitive_type('voidptr')
	}

	if child.node.type_name == .none_ {
		return types.new_primitive_type('none')
	}

	return types.unknown_type
}
