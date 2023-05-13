module psi

import analyzer.psi.types

pub struct ParameterDeclaration {
	PsiElementImpl
}

pub fn (n &ParameterDeclaration) get_type() types.Type {
	if builtin_typ := n.find_child_by_type(.builtin_type) {
		return types.new_primitive_type(builtin_typ.get_text())
	}
	if ref := n.find_child_by_type(.type_reference_expression) {
		return types.new_struct_type(ref.get_text())
	}

	return types.unknown_type
}

pub fn (n &ParameterDeclaration) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &ParameterDeclaration) name() string {
	if id := n.identifier() {
		return id.get_text()
	}

	return ''
}

pub fn (n &ParameterDeclaration) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := n.find_child_by_type(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}
