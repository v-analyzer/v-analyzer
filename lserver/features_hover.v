module lserver

import lsp
import analyzer.psi
import lserver.documentation

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) ?lsp.Hover {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	println('hovering at ' + params.position.str() + ' in file ' + file.uri)

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return none
	}

	mut provider := documentation.Provider{}
	doc_element := ls.find_documentation_element(element)?

	if content := provider.documentation(doc_element) {
		return lsp.Hover{
			contents: lsp.hover_markdown_string(content)
			range: lsp.Range{}
		}
	}

	return lsp.Hover{
		contents: lsp.hover_markdown_string(element.type_name() + ': ' +
			element.node.type_name.str())
		range: text_range_to_lsp_range(element.text_range())
	}
}

fn (mut ls LanguageServer) find_documentation_element(element psi.PsiElement) ?psi.PsiElement {
	if element is psi.Identifier {
		parent := element.parent()?
		if parent is psi.ReferenceExpressionBase {
			return ls.analyzer_instance.resolver.resolve_local(parent) or {
				println('cannot resolve reference ' + parent.name())
				return none
			}
		}

		if parent is psi.PsiNamedElement {
			return parent as psi.PsiElement
		}
	}

	return element
}
