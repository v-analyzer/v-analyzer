module lserver

import lsp
import os

const temp_formatting_file_path = os.join_path(os.temp_dir(), 'spavn-analyzer-formatting-temp.v')

pub fn (mut ls LanguageServer) formatting(params lsp.DocumentFormattingParams, mut wr ResponseWriter) ![]lsp.TextEdit {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return error('Cannot format not opened file') }

	os.write_file(lserver.temp_formatting_file_path, file.psi_file.source_text) or {
		return error('Cannot write temp file for formatting')
	}

	mut fmt_proc := ls.launch_tool('fmt', lserver.temp_formatting_file_path)!
	defer {
		fmt_proc.close()
	}
	fmt_proc.wait()

	if fmt_proc.code > 0 {
		errors := fmt_proc.stderr_slurp().trim_space()
		wr.show_message(errors, .info)
		return error('Formatting failed: ${errors}')
	}

	mut output := fmt_proc.stdout_slurp()
	$if windows {
		output = output.replace('\r\r', '\r')
	}

	return [
		lsp.TextEdit{
			range: text_range_to_lsp_range(file.psi_file.root().text_range())
			new_text: output
		},
	]
}
