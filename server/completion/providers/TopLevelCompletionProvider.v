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

struct TopLevelVariant {
	search_text string
	insert_text string
}

pub const top_level_map = {
	'fn name() { ... }':       TopLevelVariant{'fn', 'fn \${1:name}($2) {\n\t$0\n}'}
	'struct Name { ... }':     TopLevelVariant{'struct', 'struct \${1:Name} {\n\t$0\n}'}
	'interface IName { ... }': TopLevelVariant{'interface', 'interface \${1:IName} {\n\t$0\n}'}
	'enum Colors { ... }':     TopLevelVariant{'enum', 'enum \${1:Colors} {\n\t$0\n}'}
	'type MyString = string':  TopLevelVariant{'type', 'type \${1:MyString} = \${2:string}$0'}
	'const secret = 100':      TopLevelVariant{'const', 'const \${1:secret} = \${2:100}$0'}
}

pub struct TopLevelCompletionProvider {}

fn (k &TopLevelCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_top_level
}

fn (mut k TopLevelCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	k.pub_keyword(mut result)
}

fn (mut k TopLevelCompletionProvider) pub_keyword(mut result completion.CompletionResultSet) {
	for label, variant in providers.top_level_map {
		result.add_element(lsp.CompletionItem{
			label: label
			kind: .keyword
			filter_text: variant.search_text
			insert_text: variant.insert_text
			insert_text_format: .snippet
		})
	}

	for label, variant in providers.top_level_map {
		result.add_element(lsp.CompletionItem{
			label: 'pub ${label}'
			kind: .keyword
			filter_text: 'pub ${variant.search_text}'
			insert_text: 'pub ${variant.insert_text}'
			insert_text_format: .snippet
		})
	}

	result.add_element(lsp.CompletionItem{
		label: 'import'
		kind: .keyword
		insert_text: 'import '
	})
}
