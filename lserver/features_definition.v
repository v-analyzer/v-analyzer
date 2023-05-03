module lserver

import lsp
import analyzer.ir
import os
import analyzer.parser
import analyzer.indexer

pub fn (mut ls LanguageServer) definition(params lsp.TextDocumentPositionParams, mut wr ResponseWriter) ![]lsp.LocationLink {
	content := os.read_file(params.text_document.uri.path())!
	res := parser.parse_code(content)

	lines := content.split_into_lines()
	lines_offset := lines[..params.position.line].join('\n').len + params.position.character

	element := ir.find_element_at(res, lines_offset)

	if element is ir.Identifier {
		data := ls.analyzer_instance.find_function(element.value) or {
			struct_data := ls.analyzer_instance.find_struct(element.value) or { return [] }
			return [
				lsp.LocationLink{
					target_uri: 'file://' + struct_data.filepath
					target_range: pos_to_range(struct_data.pos)
					target_selection_range: pos_to_range(struct_data.pos)
				},
			]
		}
		return [
			lsp.LocationLink{
				target_uri: 'file://' + data.filepath
				target_range: pos_to_range(data.pos)
				target_selection_range: pos_to_range(data.pos)
			},
		]
	}

	return []
}

fn pos_to_range(pos indexer.Pos) lsp.Range {
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
