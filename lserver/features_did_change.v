module lserver

import lsp
import analyzer
import time

pub fn (mut ls LanguageServer) did_change(params lsp.DidChangeTextDocumentParams, mut wr ResponseWriter) {
	uri := params.text_document.uri.normalize()
	mut file := ls.opened_files[uri] or {
		println('file not opened')
		return
	}
	new_content := params.content_changes[0].text
	file.psi_file.reparse(new_content)
	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: file.version++
		psi_file: file.psi_file
	}

	ls.analyzer_instance.indexer.mark_as_dirty(uri.path(), new_content) or {
		println('Error marking "${uri}" as dirty: ${err}')
	}

	watch := time.new_stopwatch(auto_start: true)
	ls.analyzer_instance.update_stub_indexes([file.psi_file])
	println('Updated stub indexes in ${watch.elapsed()}')

	println('Reparsed file ${uri}')
}
