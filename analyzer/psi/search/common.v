module search

import analyzer.psi
import analyzer.psi.types

// is_implemented checks if the given symbol (methods and fields) implements the given interface (methods and fields).
fn is_implemented(iface_methods []psi.PsiElement, iface_fields []psi.PsiElement, symbol_methods []psi.PsiElement, symbol_fields []psi.PsiElement) bool {
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

	mut symbol_fields_struct := map[string]psi.StructFieldDeclaration{}
	mut symbol_fields_interface := map[string]psi.InterfaceFieldDeclaration{}
	for symbol_field in symbol_fields {
		if symbol_field is psi.StructFieldDeclaration {
			symbol_fields_struct[symbol_field.name()] = *symbol_field
		}
		if symbol_field is psi.InterfaceFieldDeclaration {
			symbol_fields_interface[symbol_field.name()] = *symbol_field
		}
	}

	for iface_field in iface_fields {
		if iface_field is psi.StructFieldDeclaration {
			if iface_field.is_embedded_definition() {
				continue
			}

			if iface_field.name() !in symbol_fields_struct {
				// if at least one field is not implemented, then the whole interface is not implemented
				return false
			}
		}
		if iface_field is psi.InterfaceFieldDeclaration {
			if iface_field.is_embedded_definition() {
				continue
			}

			if iface_field.name() !in symbol_fields_interface {
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
		if iface_field is psi.StructFieldDeclaration {
			symbol_field := symbol_fields_struct[iface_field.name()]
			iface_type := iface_field.get_type()
			symbol_type := symbol_field.get_type()
			if iface_type.qualified_name() != symbol_type.qualified_name() {
				return false
			}
		}
		if iface_field is psi.InterfaceFieldDeclaration {
			symbol_field := symbol_fields_interface[iface_field.name()]
			iface_type := iface_field.get_type()
			symbol_type := symbol_field.get_type()
			if iface_type.qualified_name() != symbol_type.qualified_name() {
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
