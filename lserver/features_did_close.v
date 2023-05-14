module lserver

import lsp

pub fn (mut ls LanguageServer) did_close(params lsp.DidCloseTextDocumentParams, mut wr ResponseWriter) {
	uri := params.text_document.uri.normalize()
	if file := ls.opened_files[uri] {
		file.psi_file.tree.raw_tree.free()
	}

	ls.opened_files.delete(uri)
	println('closed file: ${uri}')
}
