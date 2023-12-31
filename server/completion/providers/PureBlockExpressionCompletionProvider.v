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

pub struct PureBlockExpressionCompletionProvider {}

fn (k &PureBlockExpressionCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.expression()
}

fn (mut k PureBlockExpressionCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	one_line := if parent := ctx.element.parent_nth(2) {
		if parent.node.type_name == .simple_statement {
			false
		} else {
			true
		}
	} else {
		true
	}

	insert_text := if one_line {
		'unsafe { $0 }'
	} else {
		'unsafe {\n\t$0\n}'
	}

	result.add_element(lsp.CompletionItem{
		label: 'unsafe { ... }'
		kind: .keyword
		insert_text: insert_text
		insert_text_format: .snippet
		insert_text_mode: .adjust_indentation
	})
}
