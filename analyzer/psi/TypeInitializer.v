module psi

import analyzer.psi.types

pub struct TypeInitializer {
	PsiElementImpl
}

fn (n &TypeInitializer) expr() {}

fn (n &TypeInitializer) get_type() types.Type {
	type_element := n.find_child_by_type(.plain_type) or { return types.unknown_type }

	type_reference := type_element.first_child() or { return types.unknown_type }

	if type_reference is TypeReferenceExpression {
		resolved := type_reference.resolve() or { return types.unknown_type }
		if resolved is StructDeclaration {
			return types.new_struct_type(resolved.name())
		}
		return types.unknown_type
	}

	return types.unknown_type
}
