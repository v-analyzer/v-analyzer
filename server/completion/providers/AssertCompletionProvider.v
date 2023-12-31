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

pub struct AssertCompletionProvider {}

fn (_ &AssertCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	if !ctx.is_test_file {
		return false
	}
	return ctx.is_statement || ctx.is_assert_statement
}

fn (mut _ AssertCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'assert expr'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: 'assert \${1:expr}'
	})

	result.add_element(lsp.CompletionItem{
		label: 'assert expr, message'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: "assert \${1:expr}, '\${2:message}'$0"
	})
}
