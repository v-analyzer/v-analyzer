module lserver

import lsp
import analyzer
import analyzer.psi
import analyzer.parser

pub fn (mut ls LanguageServer) did_open(params lsp.DidOpenTextDocumentParams, mut wr ResponseWriter) {
	src := params.text_document.text
	uri := params.text_document.uri.normalize()

	res := parser.parse_code(src)
	psi_file := psi.new_psi_file(uri.path(), res.tree, res.source_text)

	// mut visitor := psi.PrinterVisitor{}
	// psi_file.root().accept_mut(mut visitor)
	// visitor.print()

	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: 0
		psi_file: psi_file
	}

	println('opened file: ${uri}')
}
