module lserver

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) ?lsp.Hover {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	println('hovering at ' + params.position.str() + ' in file ' + file.uri)

	offset := file.find_offset(params.position)
	element := file.psi_file.find_reference_at(offset) or {
		println('cannot find reference at ' + offset.str())
		return none
	}

	if element is psi.ReferenceExpression {
		resolved := ls.analyzer_instance.resolver.resolve_local(file, element) or {
			println('cannot resolve reference ' + element.str())
			return none
		}

		if resolved is psi.PsiTypedElement {
			return lsp.Hover{
				contents: lsp.hover_markdown_string('type: ' + resolved.get_type().name())
				range: lsp.Range{}
			}
		}
	}

	return lsp.Hover{
		contents: lsp.hover_markdown_string('hello')
		range: lsp.Range{}
	}
}
