module server

import lsp

pub fn (mut ls LanguageServer) did_save(params lsp.DidSaveTextDocumentParams) {}
