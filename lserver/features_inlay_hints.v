module lserver

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) inlay_hints(params lsp.InlayHintParams, mut wr ResponseWriter) ?[]lsp.InlayHint {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	if file.psi_file.source_text.len() > 30000 {
		return none
	}

	mut visitor := InlayHintsVisitor{}
	file.psi_file.root().accept_mut(mut visitor)

	return visitor.result
}

struct InlayHintsVisitor {
mut:
	result []lsp.InlayHint = []lsp.InlayHint{cap: 10}
}

fn (mut v InlayHintsVisitor) visit_element(element psi.PsiElement) {
	if !v.visit_element_impl(psi.create_element(element.node, element.containing_file)) {
		return
	}
	mut child := element.first_child() or { return }
	for {
		child.accept_mut(mut v)
		child = child.next_sibling() or { break }
	}
}

fn (mut v InlayHintsVisitor) visit_element_impl(element psi.PsiElement) bool {
	if element is psi.VarDefinition {
		typ := element.get_type()
		range := element.text_range()

		v.result << lsp.InlayHint{
			position: lsp.Position{
				line: range.line
				character: range.end_column
			}
			label: ': ' + typ.readable_name()
			kind: .type_
		}
	}

	return true
}
