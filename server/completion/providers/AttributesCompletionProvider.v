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

const attributes = [
	'params',
	'noinit',
	'required',
	'skip',
	'assert_continues',
	'unsafe',
	'manualfree',
	'heap',
	'nonnull',
	'primary',
	'inline',
	'direct_array_access',
	'live',
	'flag',
	'noinline',
	'noreturn',
	'typedef',
	'console',
	'keep_args_alive',
	'omitempty',
	'json_as_number',
]

const attributes_with_colon = [
	'sql',
	'table',
	'deprecated',
	'deprecated_after',
	'export',
	'callconv',
]

pub struct AttributesCompletionProvider {}

fn (k &AttributesCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_attribute
}

fn (mut k AttributesCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	for attribute in providers.attributes {
		result.add_element(lsp.CompletionItem{
			label: attribute
			kind: .struct_
			insert_text: attribute
		})
	}

	for attribute in providers.attributes_with_colon {
		result.add_element(lsp.CompletionItem{
			label: "${attribute}: 'value'"
			kind: .struct_
			insert_text: "${attribute}: '$1'$0"
			insert_text_format: .snippet
		})
	}
}
