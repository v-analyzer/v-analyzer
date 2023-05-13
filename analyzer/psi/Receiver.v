module psi

import analyzer.psi.types

pub struct Receiver {
	PsiElementImpl
}

fn (r &Receiver) identifier() ?PsiElement {
	decl := r.find_child_by_type(.parameter_declaration)?
	return decl.find_child_by_type(.identifier) or {
		mutable_identifier := decl.find_child_by_type(.mutable_identifier) or { return none }

		return mutable_identifier.find_child_by_type(.identifier)
	}
}

pub fn (r &Receiver) name() string {
	if id := r.identifier() {
		return id.get_text()
	}

	return ''
}

pub fn (r &Receiver) get_type() types.Type {
	if builtin_typ := r.find_child_by_type(.builtin_type) {
		return types.new_primitive_type(builtin_typ.get_text())
	}
	if ref := r.find_child_by_type(.type_reference_expression) {
		return types.new_struct_type(ref.get_text())
	}

	return types.unknown_type
}
