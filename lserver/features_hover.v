module lserver

import lsp
import os
import analyzer.parser
import analyzer.ir

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) !lsp.Hover {
	content := os.read_file(params.text_document.uri.path())!
	res := parser.parse_code(content)

	lines := content.split_into_lines()
	lines_offset := lines[..params.position.line].join('\n').len + params.position.character

	element := ir.find_element_at(res, lines_offset)

	if element is ir.Identifier {
		data := ls.analyzer_instance.find_function(element.value) or {
			return lsp.Hover{
				contents: lsp.hover_markdown_string('function ${element.value} not found')
				range: lsp.Range{}
			}
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
