module lserver

import lsp
import os
import analyzer.parser
import analyzer.ir

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) ?lsp.Hover {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	println('hovering at ' + params.position.str() + ' in file ' + file.uri)

	offset := file.find_offset(params.position)
	element := ir.find_reference_at(file.root, offset) or {
		println('cannot find reference at ' + offset.str())
		return none
	}

	if element is ir.ReferenceExpression {
		data := ls.analyzer_instance.resolver.resolve(file, element) or {
			println('cannot resolve reference ' + element.str())
			return none
		}

		return lsp.Hover{
			contents: lsp.hover_markdown_string(data.name + ' from file ' + data.filepath)
			range: lsp.Range{}
		}
	}

	return lsp.Hover{
		contents: lsp.hover_markdown_string('hello')
		range: lsp.Range{}
	}
}
