module lserver

import lsp

pub fn (mut ls LanguageServer) did_save(params lsp.DidSaveTextDocumentParams, mut wr ResponseWriter) {}
