module psi

import analyzer.psi.types

pub struct TypeInferer {
}

pub fn (_ &TypeInferer) infer_type(element PsiElement) types.Type {
	return types.unknown_type
}

pub fn (_ &TypeInferer) infer_from_plain_type(element PsiElement) types.Type {
	if element.stub_id != non_stubbed_element {
		if stub := element.stub_list().get_stub(element.stub_id) {
			type_stubs := stub.get_children_by_type(.plain_type)
			if type_stubs.len > 0 {
				text := type_stubs[0].text()
				if types.is_primitive_type(text) {
					return types.new_primitive_type(text)
				}
				return types.new_struct_type(text)
			}

			return types.unknown_type
		}
	}

	if plain_typ := element.find_child_by_type(.plain_type) {
		text := plain_typ.get_text()
		if types.is_primitive_type(text) {
			return types.new_primitive_type(text)
		}

		return types.new_struct_type(text)
	}

	return types.unknown_type
}
