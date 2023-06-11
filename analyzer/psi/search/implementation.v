module search

import analyzer.psi
import analyzer.psi.types

pub fn implementations(iface psi.InterfaceDeclaration) []psi.PsiElement {
	methods := iface.methods()
	fields := iface.fields()

	if methods.len == 0 && fields.len == 0 {
		return []
	}

	candidates := candidates_by_methods_and_fields(methods, fields)
	if candidates.len == 0 {
		return []
	}

	mut result := []psi.PsiElement{cap: 5}

	for candidate in candidates {
		if is_implemented(methods, fields, candidate) {
			result << candidate
		}
	}

	return result
}

fn is_implemented(iface_methods []psi.PsiElement, iface_fields []psi.PsiElement, symbol psi.PsiElement) bool {
	symbol_type := if symbol is psi.PsiTypedElement {
		symbol.get_type()
	} else {
		return false
	}
	symbol_methods := psi.methods_list(symbol_type)
	if symbol_methods.len == 0 && iface_methods.len != 0 {
		return false
	}
	symbol_fields := psi.fields_list(symbol_type)
	if symbol_fields.len == 0 && iface_fields.len != 0 {
		return false
	}

	mut symbol_methods_set := map[string]psi.FunctionOrMethodDeclaration{}
	for symbol_method in symbol_methods {
		if symbol_method is psi.FunctionOrMethodDeclaration {
			symbol_methods_set[symbol_method.fingerprint()] = *symbol_method
		}
	}

	for iface_method in iface_methods {
		if iface_method is psi.InterfaceMethodDeclaration {
			if iface_method.fingerprint() !in symbol_methods_set {
				// if at least one method is not implemented, then the whole interface is not implemented
				return false
			}
		}
	}

	mut symbol_fields_set := map[string]psi.FieldDeclaration{}
	for symbol_field in symbol_fields {
		if symbol_field is psi.FieldDeclaration {
			symbol_fields_set[symbol_field.name()] = *symbol_field
		}
	}

	for iface_field in iface_fields {
		if iface_field is psi.FieldDeclaration {
			if iface_field.is_embedded_definition() {
				continue
			}

			if iface_field.name() !in symbol_fields_set {
				// if at least one field is not implemented, then the whole interface is not implemented
				return false
			}
		}
	}

	for iface_method in iface_methods {
		if iface_method is psi.InterfaceMethodDeclaration {
			symbol_method := symbol_methods_set[iface_method.fingerprint()]
			if !is_method_compatible(*iface_method, symbol_method) {
				return false
			}
		}
	}

	for iface_field in iface_fields {
		if iface_field is psi.FieldDeclaration {
			symbol_field := symbol_fields_set[iface_field.name()]
			if !is_field_compatible(*iface_field, symbol_field) {
				return false
			}
		}
	}

	return true
}

fn is_method_compatible(iface_method psi.InterfaceMethodDeclaration, symbol_method psi.FunctionOrMethodDeclaration) bool {
	iface_signature := iface_method.signature() or { return false }
	symbol_signature := symbol_method.signature() or { return false }

	iface_type := iface_signature.get_type()
	symbol_type := symbol_signature.get_type()

	if iface_type is types.FunctionType {
		if symbol_type is types.FunctionType {
			iface_params := iface_type.params
			symbol_params := symbol_type.params

			if iface_params.len != symbol_params.len {
				return false
			}

			for i in 0 .. iface_params.len {
				if iface_params[i].qualified_name() != symbol_params[i].qualified_name() {
					return false
				}
			}

			if iface_type.no_result != symbol_type.no_result {
				return false
			}

			if iface_type.result.qualified_name() != symbol_type.result.qualified_name() {
				return false
			}

			return true
		}
	}

	return false
}

fn is_field_compatible(iface_field psi.FieldDeclaration, symbol_field psi.FieldDeclaration) bool {
	iface_type := iface_field.get_type()
	symbol_type := symbol_field.get_type()

	return iface_type.qualified_name() == symbol_type.qualified_name()
}

fn candidates_by_methods_and_fields(methods []psi.PsiElement, fields []psi.PsiElement) []psi.PsiElement {
	by_methods := candidates_by_methods(methods)
	by_fields := candidates_by_fields(fields)
	mut result := []psi.PsiElement{cap: by_methods.len + by_fields.len}
	result << by_methods
	result << by_fields
	return result
}

fn candidates_by_methods(methods []psi.PsiElement) []psi.PsiElement {
	mut candidates := []psi.PsiElement{cap: 5}

	for method in methods {
		if method is psi.InterfaceMethodDeclaration {
			fingerprint := method.fingerprint()

			// all methods with the same fingerprint can probably be part of struct that implements the interface
			struct_methods := stubs_index.get_elements_from_by_name(.workspace, .methods_fingerprint,
				fingerprint)

			for struct_method in struct_methods {
				if struct_method is psi.FunctionOrMethodDeclaration {
					candidates << struct_method.owner() or { continue }
				}
			}
		}
	}

	return candidates
}

fn candidates_by_fields(fields []psi.PsiElement) []psi.PsiElement {
	mut candidates := []psi.PsiElement{cap: 5}

	for field in fields {
		if field is psi.FieldDeclaration {
			fingerprint := field.name()

			// all fields with the same fingerprint can probably be part of struct that implements the interface
			struct_fields := stubs_index.get_elements_from_by_name(.workspace, .fields_fingerprint,
				fingerprint)

			for struct_field in struct_fields {
				if struct_field is psi.FieldDeclaration {
					candidates << struct_field.owner() or { continue }
				}
			}
		}
	}

	return candidates
}
