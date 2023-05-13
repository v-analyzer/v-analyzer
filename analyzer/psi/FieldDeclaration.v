module psi

import analyzer.psi.types

pub struct FieldDeclaration {
	PsiElementImpl
}

pub fn (f &FieldDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier)
}

pub fn (f &FieldDeclaration) name() string {
	if id := f.identifier() {
		return id.get_text()
	}

	return ''
}

pub fn (f &FieldDeclaration) get_type() types.Type {
	if builtin_typ := f.find_child_by_type(.builtin_type) {
		return types.new_primitive_type(builtin_typ.get_text())
	}
	if ref := f.find_child_by_type(.type_reference_expression) {
		return types.new_struct_type(ref.get_text())
	}

	return types.unknown_type
}

pub fn (f &FieldDeclaration) owner() ?PsiElement {
	return f.parent_of_type(.struct_declaration)
}
