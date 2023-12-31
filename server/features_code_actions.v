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
import json
import server.intentions

pub fn (mut ls LanguageServer) code_actions(params lsp.CodeActionParams) ?[]lsp.CodeAction {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	mut actions := []lsp.CodeAction{}

	ctx := intentions.IntentionContext.from(file.psi_file, params.range.start)

	for _, mut intention in ls.intentions {
		if !intention.is_available(ctx) {
			continue
		}

		actions << lsp.CodeAction{
			title: intention.name
			kind: lsp.refactor
			command: lsp.Command{
				title: intention.name
				command: intention.id
				arguments: [
					json.encode(IntentionData{
						file_uri: uri
						position: params.range.start
					}),
				]
			}
		}
	}

	for _, mut intention in ls.compiler_quick_fixes {
		if !intention.is_available(ctx) {
			continue
		}

		if !params.context.diagnostics.any(intention.is_matched_message(it.message)) {
			continue
		}

		actions << lsp.CodeAction{
			title: intention.name
			kind: lsp.quick_fix
			command: lsp.Command{
				title: intention.name
				command: intention.id
				arguments: [
					json.encode(IntentionData{
						file_uri: uri
						position: params.range.start
					}),
				]
			}
		}
	}

	return actions
}
