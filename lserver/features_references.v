module lserver

import lsp
import analyzer.psi

struct FindReferencesVisitor {
	element_to_find psi.PsiNamedElement
mut:
	result []psi.PsiElement
}

fn (mut f FindReferencesVisitor) elements() []psi.PsiElement {
	return f.result
}

fn (mut f FindReferencesVisitor) locations() []lsp.Location {
	return f.result.map(fn (it psi.PsiElement) lsp.Location {
		return lsp.Location{
			uri: 'file://' + it.containing_file.path()
			range: text_range_to_lsp_range(it.text_range())
		}
	})
}

fn (mut f FindReferencesVisitor) visit_element(element psi.PsiElement) {
	if !f.visit_element_impl(element) {
		return
	}
	mut child := element.first_child() or { return }
	for {
		child.accept_mut(mut f)
		child = child.next_sibling() or { break }
	}
}

fn (mut f FindReferencesVisitor) visit_element_impl(element psi.PsiElement) bool {
	resolved := f.try_resolve(element) or { return true }

	if resolved is psi.PsiNamedElement {
		if f.element_to_find.name() == resolved.name()
			&& f.element_to_find.identifier_text_range() == resolved.identifier_text_range() {
			f.result << element
			return false
		}
	}

	return true
}

fn (mut f FindReferencesVisitor) try_resolve(element psi.PsiElement) ?psi.PsiElement {
	if element.node.type_name == .reference_expression {
		if element is psi.PsiElementImpl {
			el := psi.ReferenceExpression{
				PsiElementImpl: element
			}
			return el.resolve()
		}
	}

	if element.node.type_name == .type_reference_expression {
		if element is psi.PsiElementImpl {
			el := psi.TypeReferenceExpression{
				PsiElementImpl: element
			}
			return el.resolve()
		}
	}

	return none
}

pub fn (mut ls LanguageServer) references(params lsp.ReferenceParams, mut wr ResponseWriter) []lsp.Location {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return [] }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return []
	}

	element_to_find := resolve_identifier(element)

	if element_to_find is psi.PsiNamedElement {
		mut visit := FindReferencesVisitor{
			element_to_find: element_to_find
		}
		file.psi_file.root().accept_mut(mut visit)
		return visit.locations()
	}

	return []
}

fn text_range_to_lsp_range(pos psi.TextRange) lsp.Range {
	return lsp.Range{
		start: lsp.Position{
			line: pos.line
			character: pos.column
		}
		end: lsp.Position{
			line: pos.end_line
			character: pos.end_column
		}
	}
}
