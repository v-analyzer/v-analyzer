// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module psi

import analyzer.psi.types

pub fn own_methods_list(typ types.Type) []PsiElement {
	module_name := typ.module_name()
	name := typ.name()
	if module_name == '' || name == '' {
		return []
	}

	key := '${module_name}.${name}'
	methods := stubs_index.get_elements_by_name(.methods, key)
	return methods
}

pub fn fields_list(typ types.Type) []PsiElement {
	name := typ.qualified_name()
	structs := stubs_index.get_elements_by_name(.structs, name)
	if structs.len == 0 {
		return []
	}

	struct_ := structs.first()
	if struct_ is StructDeclaration {
		return struct_.fields()
	}
	return []
}

pub fn methods_list(typ types.Type) []PsiElement {
	mut result := own_methods_list(typ)

	unwrapped := types.unwrap_alias_type(types.unwrap_pointer_type(typ))
	if unwrapped.qualified_name() != typ.qualified_name() {
		// if after unwrapping alias type we get another type, we need
		// to collect their methods as well.
		result << own_methods_list(unwrapped)
	}

	if typ is types.InterfaceType {
		if interface_ := find_interface(typ.qualified_name()) {
			embedded_types := interface_.embedded_definitions().map(it.get_type())
			for embedded_type in embedded_types {
				result << methods_list(embedded_type)
			}
		}
	}

	if typ is types.StructType {
		if struct_ := find_struct(typ.qualified_name()) {
			embedded_types := struct_.embedded_definitions().map(it.get_type())
			for embedded_type in embedded_types {
				result << methods_list(embedded_type)
			}
		}
	}

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

pub fn static_methods_list(typ types.Type) []PsiElement {
	module_name := typ.module_name()
	name := typ.name()
	if module_name == '' || name == '' {
		return []
	}

	key := '${module_name}.${name}'
	methods := stubs_index.get_elements_by_name(.static_methods, key)
	return methods
}
