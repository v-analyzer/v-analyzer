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

	comment := f.find_child_by_type(.comment) or { return '' }
	return comment.get_text().trim_left('//').trim(' \t')
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

pub fn (f FieldDeclaration) stub() ?&StubBase {
	return none
}
