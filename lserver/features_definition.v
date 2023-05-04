module lserver

import lsp
import analyzer.ir
import analyzer.indexer

pub fn (mut ls LanguageServer) definition(params lsp.TextDocumentPositionParams, mut wr ResponseWriter) ?[]lsp.LocationLink {
	uri := params.text_document.uri.normalize()
	println('definition in ' + uri.str())
	file := ls.get_file(uri) or { return none }

	offset := file.find_offset(params.position)
	element := ir.find_reference_at(file.root, offset) or {
		println('cannot find reference at ' + offset.str())
		return none
	}

	if element is ir.ReferenceExpression {
		data := ls.analyzer_instance.resolver.resolve(file, element) or {
			println('cannot resolve ' + element.str())
			return none
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
