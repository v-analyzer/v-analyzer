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
import json
import server.intentions

pub struct IntentionData {
pub:
	file_uri string
	position lsp.Position
}

pub fn (mut ls LanguageServer) execute_command(params lsp.ExecuteCommandParams) ? {
	mut intention := ls.find_intention_or_quickfix(params.command)?

	arguments := json.decode([]string, params.arguments) or { []string{} }

	argument := json.decode(IntentionData, arguments[0]) or {
		loglib.with_fields({
			'command':  params.command
			'argument': params.arguments
		}).warn('Got invalid argument')
		return
	}

	file_uri := argument.file_uri
	file := ls.get_file(file_uri)?
	pos := argument.position

	ctx := intentions.IntentionContext.from(file.psi_file, pos)
	edits := intention.invoke(ctx) or { return }

	ls.client.apply_edit(edit: edits)
}

pub fn (mut ls LanguageServer) find_intention_or_quickfix(name string) ?intentions.Intention {
	if i := ls.intentions[name] {
		return i
	}

	if qf := ls.compiler_quick_fixes[name] {
		return qf as intentions.Intention
	}

	return none
}
