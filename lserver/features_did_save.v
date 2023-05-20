module lserver

import lsp

pub fn (mut ls LanguageServer) did_save(params lsp.DidSaveTextDocumentParams, mut wr ResponseWriter) {
	uri := params.text_document.uri.normalize()
}
