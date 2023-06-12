module server

import lsp
import loglib
import analyzer.psi
import analyzer.psi.search

pub fn (mut ls LanguageServer) rename(params lsp.RenameParams, mut wr ResponseWriter) !lsp.WorkspaceEdit {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return error('cannot rename element from not opened file') }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		loglib.with_fields({
			'offset': offset.str()
		}).warn('Cannot find element')
		return error('cannot find element at ' + offset.str())
	}

	references := search.references(element, include_declaration: true)
	edits := elements_to_text_edits(references, params.new_name)

	return lsp.WorkspaceEdit{
		changes: {
			uri: edits
		}
	}
}

fn elements_to_text_edits(elements []psi.PsiElement, new_name string) []lsp.TextEdit {
	mut result := []lsp.TextEdit{cap: elements.len}

	for element in elements {
		range := if element is psi.PsiNamedElement {
			element.identifier_text_range()
		} else {
			element.text_range()
		}
		result << lsp.TextEdit{
			range: text_range_to_lsp_range(range)
			new_text: new_name
		}
	}

	return result
}
