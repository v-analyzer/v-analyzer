module psi

import analyzer.psi.types

pub fn own_methods_list(typ types.Type) []PsiElement {
	name := typ.qualified_name()
	methods := stubs_index.get_elements_by_name(.methods, name)
	return methods
}

pub fn methods_list(typ types.Type) []PsiElement {
	own_methods := own_methods_list(typ)
	unwrapped := types.unwrap_alias_type(types.unwrap_pointer_type(typ))

	if unwrapped.qualified_name() == typ.qualified_name() {
		return own_methods
	}

	inherited_methods := own_methods_list(unwrapped)

	mut result := []PsiElement{cap: own_methods.len + inherited_methods.len}
	result << own_methods
	result << inherited_methods
	return result
}

pub fn find_method(typ types.Type, name string) ?PsiElement {
	methods := methods_list(typ)
	for method in methods {
		if method is PsiNamedElement {
			if method.name() == name {
				return method as PsiElement
			}
		}
	}
	return none
}
