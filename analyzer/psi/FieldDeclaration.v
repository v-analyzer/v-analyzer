module psi

import analyzer.psi.types

pub struct FieldDeclaration {
	PsiElementImpl
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
			builtin_type_stubs := stub.get_children_by_type(.builtin_type)
			if builtin_type_stubs.len > 0 {
				return types.new_primitive_type(builtin_type_stubs[0].text())
			}

			return types.unknown_type
		}
	}

	if builtin_typ := f.find_child_by_type(.builtin_type) {
		return types.new_primitive_type(builtin_typ.get_text())
	}
	if ref := f.find_child_by_type(.type_reference_expression) {
		return types.new_struct_type(ref.get_text())
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
