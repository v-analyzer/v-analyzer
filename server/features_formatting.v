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
import os
import server.tform

const temp_formatting_file_path = os.join_path(os.temp_dir(), 'v-analyzer-formatting-temp.v')

pub fn (mut ls LanguageServer) formatting(params lsp.DocumentFormattingParams) ![]lsp.TextEdit {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return error('Cannot format not opened file') }

	os.write_file(server.temp_formatting_file_path, file.psi_file.source_text) or {
		return error('Cannot write temp file for formatting: ${err}')
	}

	mut fmt_proc := ls.launch_tool('fmt', server.temp_formatting_file_path)!
	defer {
		fmt_proc.close()
	}
	fmt_proc.wait()

	if fmt_proc.code != 0 {
		errors := fmt_proc.stderr_slurp().trim_space()
		ls.client.show_message(errors, .info)
		return error('Formatting failed: ${errors}')
	}

	mut output := fmt_proc.stdout_slurp()
	$if windows {
		output = output.replace('\r\r', '\r')
	}

	return [
		lsp.TextEdit{
			range: tform.text_range_to_lsp_range(file.psi_file.root().text_range())
			new_text: output
		},
	]
}
