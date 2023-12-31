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
module providers

import server.completion
import lsp

const compile_time_constant = {
	'FN':        'The name of the current function'
	'METHOD':    'The name of the current method'
	'MOD':       'The name of the current module'
	'STRUCT':    'The name of the current struct'
	'FILE':      'The absolute path:the current file'
	'LINE':      'The line number of the current line (as a string)'
	'FILE_LINE': 'The relative path and line number of the current line (like @FILE:@LINE)'
	'COLUMN':    'The column number of the current line (as a string)'
	'VEXE':      'The absolute path:the V compiler executable'
	'VEXEROOT':  "The absolute path:the V compiler executable's root directory"
	'VHASH':     "The V compiler's git hash"
	'VMOD_FILE': 'The content:the nearest v.mod file'
	'VMODROOT':  "The absolute path:the nearest v.mod file's directory"
}

pub struct CompileTimeConstantCompletionProvider {}

fn (_ &CompileTimeConstantCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.after_at
}

fn (mut _ CompileTimeConstantCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	for constant, description in providers.compile_time_constant {
		result.add_element(lsp.CompletionItem{
			label: '@${constant}'
			kind: .constant
			detail: description
			insert_text: constant
		})
	}
}
