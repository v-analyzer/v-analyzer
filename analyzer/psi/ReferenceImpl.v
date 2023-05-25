module psi

import analyzer.psi.types
import utils

pub struct ReferenceImpl {
	element        ReferenceExpressionBase
	file           &PsiFileImpl
	for_types      bool
	for_attributes bool
}

pub fn new_reference(file &PsiFileImpl, element ReferenceExpressionBase, for_types bool) &ReferenceImpl {
	return &ReferenceImpl{
		element: element
		file: file
		for_types: for_types
	}
}

pub fn new_attribute_reference(file &PsiFileImpl, element ReferenceExpressionBase) &ReferenceImpl {
	return &ReferenceImpl{
		element: element
		file: file
		for_attributes: true
	}
}

fn (r &ReferenceImpl) element() PsiElement {
	return r.element as PsiElement
}

pub fn (r &ReferenceImpl) resolve() ?PsiElement {
	sub := SubResolver{
		containing_file: r.file
		element: r.element
		for_types: r.for_types
		for_attributes: r.for_attributes
	}
	mut processor := ResolveProcessor{
		containing_file: r.file
		ref: r.element
	}
	sub.process_resolve_variants(mut processor)

	if processor.result.len > 0 {
		return processor.result.first()
	}
	return none
}

pub struct SubResolver {
	containing_file &PsiFileImpl
	element         ReferenceExpressionBase
	for_types       bool
	for_attributes  bool
}

fn (r &SubResolver) element() PsiElement {
	return r.element as PsiElement
}

pub fn (r &SubResolver) process_resolve_variants(mut processor PsiScopeProcessor) bool {
	return if qualifier := r.element.qualifier() {
		r.process_qualifier_expression(qualifier, mut processor)
	} else {
		r.process_unqualified_resolve(mut processor)
	}
}

pub fn (r &SubResolver) process_qualifier_expression(qualifier PsiElement, mut processor PsiScopeProcessor) bool {
	if qualifier is PsiTypedElement {
		typ := TypeInferer{}.infer_type(qualifier as PsiElement)
		if typ !is types.UnknownType {
			r.process_type(typ, mut processor)
		}
	}

	return true
}

pub fn (_ &SubResolver) calc_methods(typ types.Type) []PsiElement {
	name := typ.qualified_name()
	methods := stubs_index.get_elements_by_name(.methods, name)
	return methods
}

pub fn (r &SubResolver) process_type(typ types.Type, mut processor PsiScopeProcessor) bool {
	if typ is types.StructType {
		if struct_ := r.find_struct(stubs_index, typ.name()) {
			for field in struct_.fields() {
				if !processor.execute(field) {
					return false
				}
			}

			methods := r.calc_methods(typ)
			for method in methods {
				if !processor.execute(method) {
					return false
				}
			}
		}
	}
	if typ is types.EnumType {
		if enum_ := r.find_enum(stubs_index, typ.name()) {
			for field in enum_.fields() {
				if !processor.execute(field) {
					return false
				}
			}
		}
	}
	if typ is types.PointerType {
		return r.process_type(typ.inner, mut processor)
	}
	return true
}

pub fn (r &SubResolver) process_unqualified_resolve(mut processor PsiScopeProcessor) bool {
	if r.for_attributes {
		return r.resolve_attribute(mut processor)
	}

	if parent := r.element().parent() {
		if parent is FieldName {
			return r.process_type_initializer_field(mut processor)
		}
	}

	if !r.process_block(mut processor) {
		return false
	}
	if !r.process_file(mut processor) {
		return false
	}

	element := r.element()
	if element is PsiNamedElement {
		if !r.for_types {
			if func := r.find_function(stubs_index, element.name()) {
				if !processor.execute(func) {
					return false
				}
			}

			if constant := r.find_constant(stubs_index, element.name()) {
				if !processor.execute(constant) {
					return false
				}
			}
		}

		if struct_ := r.find_struct(stubs_index, element.name()) {
			if !processor.execute(struct_) {
				return false
			}
		}

		if enum_ := r.find_enum(stubs_index, element.name()) {
			if !processor.execute(enum_) {
				return false
			}
		}

		if struct_ := r.find_type_alias(stubs_index, element.name()) {
			if !processor.execute(struct_) {
				return false
			}
		}
	}

	return true
}

pub fn (r &SubResolver) walk_up(element PsiElement, mut processor PsiScopeProcessor) bool {
	mut run := element
	for {
		if mut run is ForStatement {
			vars := run.var_definitions()
			for v in vars {
				if !processor.execute(v) {
					return false
				}
			}
		}

		if mut run is Block {
			if !run.process_declarations(mut processor) {
				return false
			}

			if !r.process_parameters(run, mut processor) {
				return false
			}

			if !r.process_receiver(run, mut processor) {
				return false
			}
		}

		run = run.parent() or { break }
	}
	return true
}

pub fn (_ &SubResolver) process_parameters(b Block, mut processor PsiScopeProcessor) bool {
	parent := b.parent() or { return true }

	if parent is SignatureOwner {
		signature := parent.signature() or { return true }

		params := signature.parameters()
		for param in params {
			if !processor.execute(param) {
				return false
			}
		}
	}

	return true
}

pub fn (_ &SubResolver) process_receiver(b Block, mut processor PsiScopeProcessor) bool {
	parent := b.parent() or { return true }

	if parent is FunctionOrMethodDeclaration {
		receiver := parent.receiver() or { return true }
		if !processor.execute(receiver) {
			return false
		}
	}

	return true
}

pub fn (r &SubResolver) process_block(mut processor PsiScopeProcessor) bool {
	if r.containing_file.is_stub_based() {
		return true
	}

	// mut delegate := ResolveProcessor{
	// 	...processor
	// }
	// if delegate.result.len == 0 {
	// 	return true
	// }
	//
	// for result in delegate.result {
	// 	processor.result << result
	// }

	return r.walk_up(r.element as PsiElement, mut processor)
}

pub fn (r &SubResolver) process_file(mut processor PsiScopeProcessor) bool {
	if r.containing_file.is_stub_based() {
		return true
	}

	return r.containing_file.process_declarations(mut processor)
}

pub fn (r &SubResolver) process_type_initializer_field(mut processor PsiScopeProcessor) bool {
	init_expr := r.element().parent_of_type(.type_initializer) or { return true }
	if init_expr is PsiTypedElement {
		typ := types.unwrap_pointer_type(TypeInferer{}.infer_type(init_expr as PsiElement))
		if typ is types.StructType {
			if struct_ := r.find_struct(stubs_index, typ.name()) {
				fields := struct_.fields()
				for field in fields {
					if !processor.execute(field) {
						return false
					}
				}
			}
		}
	}

	return true
}

pub fn (_ &SubResolver) find_function(stubs_index StubIndex, name string) ?&FunctionOrMethodDeclaration {
	found := stubs_index.get_elements_by_name(.functions, name)
	if found.len != 0 {
		first := found.first()
		if first is FunctionOrMethodDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_struct(stubs_index StubIndex, name string) ?&StructDeclaration {
	found := stubs_index.get_elements_by_name(.structs, name)
	if found.len != 0 {
		first := found.first()
		if first is StructDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_enum(stubs_index StubIndex, name string) ?&EnumDeclaration {
	found := stubs_index.get_elements_by_name(.enums, name)
	if found.len != 0 {
		first := found.first()
		if first is EnumDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_constant(stubs_index StubIndex, name string) ?&ConstantDefinition {
	found := stubs_index.get_elements_by_name(.constants, name)
	if found.len != 0 {
		first := found.first()
		if first is ConstantDefinition {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_type_alias(stubs_index StubIndex, name string) ?&TypeAliasDeclaration {
	found := stubs_index.get_elements_by_name(.type_aliases, name)
	if found.len != 0 {
		first := found.first()
		if first is TypeAliasDeclaration {
			return first
		}
	}
	return none
}

pub fn (_ &SubResolver) find_attribute(stubs_index StubIndex, name string) ?&StructDeclaration {
	found := stubs_index.get_elements_by_name(.attributes, name)
	if found.len != 0 {
		first := found.first()
		if first is StructDeclaration {
			return first
		}
	}
	return none
}

pub fn (r &SubResolver) resolve_attribute(mut processor PsiScopeProcessor) bool {
	element := r.element()
	if element is PsiNamedElement {
		if attr := r.find_attribute(stubs_index, element.name()) {
			if !processor.execute(attr) {
				return false
			}
		}
	}

	return true
}

pub struct ResolveProcessor {
	containing_file &PsiFileImpl
	ref             ReferenceExpressionBase
mut:
	result []PsiElement
}

fn (mut r ResolveProcessor) execute(element PsiElement) bool {
	if element.is_equal(r.ref as PsiElement) {
		r.result << element
		return false
	}
	if element is PsiNamedElement {
		mut name := element.name()
		if name.ends_with('Attribute') {
			name = utils.pascal_case_to_snake_case(name.trim_string_right('Attribute'))
		}
		ref_name := r.ref.name()
		if name == ref_name {
			r.result << element as PsiElement
			return false
		}
	}
	return true
}
