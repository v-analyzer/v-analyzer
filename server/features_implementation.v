module server

import lsp
import loglib
import analyzer.psi.search
import analyzer.psi

pub fn (mut ls LanguageServer) implementation(params lsp.TextDocumentPositionParams, mut _ ResponseWriter) ?[]lsp.Location {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		loglib.with_fields({
			'offset': offset.str()
		}).warn('Cannot find element')
		return none
	}

	interface_declaration := element.parent_of_type(.interface_declaration) or {
		loglib.with_fields({
			'element':      element.get_text()
			'text_range':   element.text_range().str()
			'element_type': element.element_type().str()
		}).warn('Element is not inside an interface declaration')
		return none
	}

	if interface_declaration is psi.InterfaceDeclaration {
		implementations := search.implementations(*interface_declaration)
		return elements_to_locations(implementations)
	}

	return none
}
