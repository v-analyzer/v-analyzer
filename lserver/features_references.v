module lserver

import lsp
import analyzer.psi
import analyzer.psi.search

pub fn (mut ls LanguageServer) references(params lsp.ReferenceParams, mut wr ResponseWriter) []lsp.Location {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return [] }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return []
	}

	elems := search.references(element)
	return elements_to_locations(elems)
}

fn elements_to_locations(elements []psi.PsiElement) []lsp.Location {
	return elements
		.map(fn (it psi.PsiElement) lsp.Location {
			return lsp.Location{
				uri: 'file://' + it.containing_file.path()
				range: text_range_to_lsp_range(it.text_range())
			}
		})
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
