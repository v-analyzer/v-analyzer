module psi

import analyzer.psi.types

pub struct FieldDeclaration {
	PsiElementImpl
}

pub fn (f &FieldDeclaration) doc_comment() string {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.comment
		}
	}

	if comment := f.find_child_by_type(.comment) {
		return comment.get_text().trim_left('//').trim(' \t')
	}

	return extract_doc_comment(f)
}

pub fn (f &FieldDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier)
}

pub fn (f FieldDeclaration) identifier_text_range() TextRange {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.text_range
		}
	}

	identifier := f.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (f &FieldDeclaration) name() string {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			return stub.name
		}
	}

	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f &FieldDeclaration) get_type() types.Type {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
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

	if plain_typ := f.find_child_by_type(.plain_type) {
		text := plain_typ.get_text()
		if types.is_primitive_type(text) {
			return types.new_primitive_type(text)
		}

		return types.new_struct_type(text)
	}

	return types.unknown_type
}

pub fn (f &FieldDeclaration) owner() ?PsiElement {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			if parent := stub.parent_of_type(.struct_declaration) {
				if parent.is_valid() {
					return parent.get_psi()
				}
			}
			return none
		}
	}

	return f.parent_of_type(.struct_declaration)
}

pub fn (f &FieldDeclaration) scope() ?&StructFieldScope {
	if f.stub_id != non_stubbed_element {
		if stub := f.stubs_list.get_stub(f.stub_id) {
			if parent := stub.sibling_of_type_backward(.struct_field_scope) {
				if parent.is_valid() {
					element := parent.get_psi()?
					if element is StructFieldScope {
						return element
					}
					return none
				}
			}
			return none
		}
	}

	element := f.sibling_of_type_backward(.struct_field_scope)?
	if element is StructFieldScope {
		return element
	}
	return none
}

pub fn (f &FieldDeclaration) is_mutable_public() (bool, bool) {
	scope := f.scope() or { return false, false }
	return scope.is_mutable_public()
}

pub fn (f FieldDeclaration) stub() ?&StubBase {
	return none
}
