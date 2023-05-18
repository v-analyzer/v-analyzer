module lserver

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) rename(params lsp.RenameParams, mut wr ResponseWriter) !lsp.WorkspaceEdit {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return error('cannot rename element from not opened file') }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return error('cannot find element at ' + offset.str())
	}

	element_to_find := resolve_identifier(element)
	if element_to_find !is psi.VarDefinition {
		return error('cannot rename non-variable element')
	}

	if element_to_find is psi.PsiNamedElement {
		mut visit := FindReferencesVisitor{
			element_to_find: element_to_find
		}
		file.psi_file.root().accept_mut(mut visit)
		elements := visit.elements()

		edits := elements_to_text_edits(elements, params.new_name)
		println('edits: ${edits}')
		return lsp.WorkspaceEdit{
			changes: {
				uri: edits
			}
		}
	}

	return error('')
}

fn elements_to_text_edits(elements []psi.PsiElement, new_name string) []lsp.TextEdit {
	mut result := []lsp.TextEdit{cap: elements.len}

	for element in elements {
		result << lsp.TextEdit{
			range: text_range_to_lsp_range(element.text_range())
			new_text: new_name
		}
	}

	return result
}
