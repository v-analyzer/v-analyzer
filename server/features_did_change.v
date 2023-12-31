// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module server

import lsp
import analyzer
import time
import loglib

pub fn (mut ls LanguageServer) did_change(params lsp.DidChangeTextDocumentParams) {
	uri := params.text_document.uri.normalize()
	mut file := ls.opened_files[uri] or {
		loglib.with_fields({
			'uri':    uri.str()
			'params': params.str()
			'caller': @METHOD
		}).error('File not opened')
		return
	}
	new_content := params.content_changes[0].text
	file.psi_file.reparse(new_content)
	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: file.version++
		psi_file: file.psi_file
	}

	ls.indexing_mng.indexer.mark_as_dirty(uri.path(), new_content) or {
		loglib.with_fields({
			'uri':    uri.str()
			'params': params.str()
			'caller': @METHOD
			'err':    err.str()
		}).error('Error marking document as dirty')
	}

	watch := time.new_stopwatch(auto_start: true)
	ls.indexing_mng.update_stub_indexes([file.psi_file])

	type_cache.clear()
	resolve_cache.clear()
	enum_fields_cache = map[string]int{}

	loglib.with_fields({
		'caller':   @METHOD
		'duration': watch.elapsed().str()
	}).info('Updated stub indexes')

	loglib.with_fields({
		'uri': uri.str()
	}).info('Reparsed file')
}
