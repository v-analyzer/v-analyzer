module lserver

import lsp
import analyzer

pub fn (mut ls LanguageServer) did_change(params lsp.DidChangeTextDocumentParams, mut wr ResponseWriter) {
	uri := params.text_document.uri.normalize()
	mut file := ls.opened_files[uri] or {
		println('file not opened')
		return
	}
	file.psi_file.reparse(params.content_changes[0].text)
	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: file.version++
		psi_file: file.psi_file
	}

	ls.analyzer_instance.indexer.mark_as_dirty(uri.path())

	println('reparsed file ${uri}')
}
