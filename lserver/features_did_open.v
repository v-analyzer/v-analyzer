module lserver

import lsp
import analyzer
import analyzer.psi

pub fn (mut ls LanguageServer) did_open(params lsp.DidOpenTextDocumentParams, mut wr ResponseWriter) {
	src := params.text_document.text
	uri := params.text_document.uri.normalize()

	psi_file := psi.parse_code(src)

	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: 0
		text: src
		psi_file: psi_file
	}

	println('opened file: ${uri}')
}
