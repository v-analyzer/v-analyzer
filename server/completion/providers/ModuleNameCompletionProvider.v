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
import os

pub struct ModuleNameCompletionProvider {}

fn (_ &ModuleNameCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	no_module_clause := if _ := ctx.element.containing_file.module_name() {
		false
	} else {
		true
	}
	return ctx.is_start_of_file && ctx.is_top_level && no_module_clause
}

fn (mut p ModuleNameCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	dir := os.dir(ctx.element.containing_file.path)
	dir_name := p.transform_module_name(os.file_name(dir))

	result.add_element(lsp.CompletionItem{
		label: 'module ${dir_name}'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: 'module ${dir_name}'
	})

	result.add_element(lsp.CompletionItem{
		label: 'module main'
		kind: .keyword
		insert_text: 'module main'
	})
}

fn (mut _ ModuleNameCompletionProvider) transform_module_name(raw_name string) string {
	return raw_name
		.replace('-', '_')
		.replace(' ', '_')
		.to_lower()
}
