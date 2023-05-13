module psi

import analyzer.psi.types

pub struct ReferenceImpl {
	element   ReferenceExpressionBase
	file      &PsiFileImpl
	for_types bool
}

pub fn new_reference(file &PsiFileImpl, element ReferenceExpressionBase, for_types bool) &ReferenceImpl {
	return &ReferenceImpl{
		element: element
		file: file
		for_types: for_types
	}
}

fn (r &ReferenceImpl) element() PsiElement {
	return r.element as PsiElement
}

fn (r &ReferenceImpl) resolve() ?PsiElement {
	return none
}

fn (r &ReferenceImpl) resolve_local() ?PsiElement {
	sub := SubResolver{
		containing_file: r.file
		element: r.element
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

struct SubResolver {
	containing_file &PsiFileImpl
	element         ReferenceExpressionBase
}

fn (r &SubResolver) element() PsiElement {
	return r.element as PsiElement
}

pub fn (r &SubResolver) process_resolve_variants(mut processor ResolveProcessor) bool {
	return if qualifier := r.element.qualifier() {
		r.process_qualifier_expression(qualifier, mut processor)
	} else {
		r.process_unqualified_resolve(mut processor)
	}
}

pub fn (r &SubResolver) process_qualifier_expression(qualifier PsiElement, mut processor ResolveProcessor) bool {
	return true
}

pub fn (r &SubResolver) process_unqualified_resolve(mut processor ResolveProcessor) bool {
	if parent := r.element().parent() {
		if parent is FieldName {
			return r.process_type_initializer_field(mut processor)
		}
	}

	if !r.process_file(mut processor) {
		return false
	}
	if !r.process_block(mut processor) {
		return false
	}
	return true
}

pub fn (r &SubResolver) walk_up(element PsiElement, mut processor ResolveProcessor) bool {
	mut run := element
	for {
		if mut run is Block {
			if !run.process_declarations(mut processor) {
				return false
			}

			if !r.process_parameters(run, mut processor) {
				return false
			}
		}

		run = run.parent() or { break }
	}
	return true
}

pub fn (r &SubResolver) process_parameters(b Block, mut processor PsiScopeProcessor) bool {
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

pub fn (r &SubResolver) process_block(mut processor ResolveProcessor) bool {
	mut delegate := ResolveProcessor{
		...processor
	}
	r.walk_up(r.element as PsiElement, mut delegate)

	if delegate.result.len == 0 {
		return true
	}

	for result in delegate.result {
		processor.result << result
	}

	return false
}

pub fn (r &SubResolver) process_file(mut processor ResolveProcessor) bool {
	return r.containing_file.process_declarations(mut processor)
}

pub fn (r &SubResolver) process_type_initializer_field(mut processor ResolveProcessor) bool {
	init_expr := r.element().parent_of_type(.type_initializer) or { return true }
	if init_expr is PsiTypedElement {
		typ := init_expr.get_type()
		if typ is types.StructType {
			ref := create_type_reference_expression(typ.name())
			println(ref.get_text())
			struct_resolved := ref.resolve_local()
			println(struct_resolved)
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
		name := element.name()
		ref_name := r.ref.name()
		if name == ref_name {
			r.result << element as PsiElement
			return false
		}
	}
	return true
}
