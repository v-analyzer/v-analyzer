module lserver

import lsp
import analyzer.psi
import tree_sitter_v as v

struct FindReferencesVisitor {
	element      psi.PsiNamedElement
	element_type v.NodeType
mut:
	result []psi.PsiElement
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
	typ := resolved.element_type()

	if resolved is psi.PsiNamedElement {
		if f.element_type == typ && f.element.name() == resolved.name() {
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
		println('cannot find reference at ' + offset.str())
		return []
	}

	named_element := element.parent() or { return [] }

	if named_element is psi.PsiNamedElement {
		mut visit := FindReferencesVisitor{
			element: named_element
			element_type: (named_element as psi.PsiElement).element_type()
		}
		file.psi_file.root().accept_mut(mut visit)

		return visit.result.map(fn (it psi.PsiElement) lsp.Location {
			return lsp.Location{
				uri: 'file://' + it.containing_file.path()
				range: text_range_to_lsp_range(it.text_range())
			}
		})
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
