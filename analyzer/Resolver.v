module analyzer

import analyzer.index
import analyzer.psi

pub struct Resolver {
	indexer &Indexer
}

pub fn (r &Resolver) resolve(file OpenedFile, element psi.ReferenceExpression) ?ResolveResult {
	sub := SubResolver{
		indexer: r.indexer
		containing_file: file.psi_file
		element: element
	}
	mut processor := ResolveProcessor{
		containing_file: file.psi_file
		ref: element
	}
	sub.process_resolve_variants(mut processor)

	println(processor.result)

	if processor.result.len > 0 {
		return processor.result.first()
	}

	return none
}

struct ResolveResult {
pub:
	filepath string
	name     string
	pos      index.Pos
}

fn new_resolve_result(containing_file psi.PsiFileImpl, element psi.PsiElement) ResolveResult {
	return ResolveResult{
		filepath: containing_file.path()
		name: if element is psi.PsiNamedElement { element.name() } else { '' }
		pos: index.Pos{
			line: int(element.node.start_point().row)
			column: int(element.node.start_point().column)
			end_line: int(element.node.end_point().row)
			end_column: int(element.node.end_point().column)
		}
	}
}

struct SubResolver {
	indexer         &Indexer
	containing_file psi.PsiFileImpl
	element         psi.ReferenceExpression
}

pub fn (r &SubResolver) process_resolve_variants(mut processor ResolveProcessor) bool {
	return if qualifier := r.element.qualifier() {
		r.process_qualifier_expression(qualifier, mut processor)
	} else {
		r.process_unqualified_resolve(mut processor)
	}
}

pub fn (r &SubResolver) process_qualifier_expression(qualifier psi.PsiElement, mut processor ResolveProcessor) bool {
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

pub fn (r &SubResolver) walk_up(element psi.PsiElement, mut processor ResolveProcessor) bool {
	mut run := element
	for {
		if mut run is psi.Block {
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
	containing_file psi.PsiFileImpl
	ref             psi.ReferenceExpression
mut:
	result []ResolveResult
}

fn (mut r ResolveProcessor) execute(element psi.PsiElement) bool {
	if element.is_equal(r.ref) {
		r.result << new_resolve_result(r.containing_file, element)
		return false
	}
	if element is psi.PsiNamedElement {
		name := element.name()
		if name == r.ref.name() {
			r.result << new_resolve_result(r.containing_file, element as psi.PsiElement)
			return false
		}
	}
	return true
}

pub fn (r &Resolver) find_function(name string) ?index.FunctionCache {
	for indexing_root in r.indexer.roots {
		for _, datum in indexing_root.index.data.data {
			for func in datum.functions {
				if func.name == name {
					return func
				}
			}
		}
	}
	return none
}

pub fn (r &Resolver) find_struct(name string) ?index.StructCache {
	for indexing_root in r.indexer.roots {
		for _, datum in indexing_root.index.data.data {
			for struct_ in datum.structs {
				if struct_.name == name {
					return struct_
				}
			}
		}
	}
	return none
}
