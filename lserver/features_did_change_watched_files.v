module lserver

import lsp

pub fn (mut ls LanguageServer) did_change_watched_files(params lsp.DidChangeWatchedFilesParams, mut wr ResponseWriter) {}
