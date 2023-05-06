module psi

pub struct ReferenceImpl {
	element ReferenceExpression
	file    PsiFileImpl
}

pub fn new_reference(file PsiFileImpl, element ReferenceExpression) &ReferenceImpl {
	return &ReferenceImpl{
		element: element
		file: file
	}
}

fn (r &ReferenceImpl) element() PsiElement {
	return r.element
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
	containing_file PsiFileImpl
	element         ReferenceExpression
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
		}

		run = run.parent() or { break }
	}
	return true
}

pub fn (r &SubResolver) process_block(mut processor ResolveProcessor) bool {
	mut delegate := ResolveProcessor{
		...processor
	}
	r.walk_up(r.element, mut delegate)

	println(delegate.result)

	for result in delegate.result {
		processor.result << result
	}

	return true
}

pub fn (r &SubResolver) process_file(mut processor ResolveProcessor) bool {
	return r.containing_file.process_declarations(mut processor)
}

pub struct ResolveProcessor {
	containing_file PsiFileImpl
	ref             ReferenceExpression
mut:
	result []PsiElement
}

fn (mut r ResolveProcessor) execute(element PsiElement) bool {
	if element.is_equal(r.ref) {
		r.result << element
		return false
	}
	if element is PsiNamedElement {
		name := element.name()
		if name == r.ref.name() {
			r.result << element as PsiElement
			return false
		}
	}
	return true
}
