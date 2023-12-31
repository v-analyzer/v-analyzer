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
import loglib
import analyzer
import analyzer.psi
import analyzer.parser

pub fn (mut ls LanguageServer) did_open(params lsp.DidOpenTextDocumentParams) {
	src := params.text_document.text
	uri := params.text_document.uri.normalize()

	res := parser.parse_code(src)
	psi_file := psi.new_psi_file(uri.path(), res.tree, res.source_text)

	ls.opened_files[uri] = analyzer.OpenedFile{
		uri: uri
		version: 0
		psi_file: psi_file
	}

	if 'no-diagnostics' !in ls.initialization_options {
		ls.run_diagnostics_in_bg(uri)
	}

	// Useful for debugging
	//
	// mut visitor := psi.PrinterVisitor{}
	// psi_file.root().accept_mut(mut visitor)
	// visitor.print()
	//
	// tree := index.build_stub_tree(psi_file, '')
	// tree.print()

	loglib.with_fields({
		'uri':              uri.str()
		'opened_files len': ls.opened_files.len.str()
	}).info('Opened file')
}
