module psi

import analyzer.psi.types

pub struct TypeInferer {
}

pub fn (_ &TypeInferer) infer_type(element PsiElement) types.Type {
	return types.unknown_type
}

pub fn (t &TypeInferer) infer_from_plain_type(element PsiElement) types.Type {
	if element.stub_id != non_stubbed_element {
		stub := element.stub_list().get_stub(element.stub_id) or { return types.unknown_type }
		type_stub := stub.get_child_by_type(.plain_type) or { return types.unknown_type }
		psi := type_stub.get_psi() or { return types.unknown_type }
		return t.convert_type(psi)
	}

	if plain_typ := element.find_child_by_type(.plain_type) {
		return t.convert_type(plain_typ)
	}

	return types.unknown_type
}

pub fn (b &TypeInferer) convert_type(plain_type ?PsiElement) types.Type {
	typ := plain_type or { return types.unknown_type }
	if plain_type !is PlainType {
		return types.unknown_type
	}

	child := typ.first_child_or_stub() or { return types.unknown_type }

	if child.element_type() == .pointer_type {
		inner := child.last_child_or_stub()
		return types.new_pointer_type(b.convert_type(inner))
	}

	if child.element_type() == .array_type {
		inner := child.last_child_or_stub()
		return types.new_array_type(b.convert_type(inner))
	}

	if child is TypeReferenceExpression {
		text := child.get_text()
		if types.is_primitive_type(text) {
			// fast path
			return types.new_primitive_type(text)
		}

		if text == 'string' {
			return types.string_type
		}

		resolved := child.resolve() or { return types.unknown_type }
		if resolved is StructDeclaration {
			return types.new_struct_type(resolved.name())
		}

		if resolved is EnumDeclaration {
			return types.new_enum_type(resolved.name())
		}

		return types.unknown_type
	}

	return types.unknown_type
}
