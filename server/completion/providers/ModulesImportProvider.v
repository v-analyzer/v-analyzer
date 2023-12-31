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

import analyzer.psi
import server.completion
import lsp

pub struct ModulesImportProvider {}

fn (m &ModulesImportProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_import_name
}

fn (mut m ModulesImportProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	element := ctx.element
	parent_path := element.parent_nth(2) or { return }
	before_path := parent_path.get_text().trim_string_right(completion.dummy_identifier)

	modules := psi.get_all_modules()

	for module_ in modules {
		if module_ == 'main' {
			continue
		}

		if !module_.starts_with(before_path) {
			continue
		}
		name_without_prefix := module_.trim_string_left(before_path)

		result.add_element(lsp.CompletionItem{
			label: name_without_prefix
			kind: .module_
			detail: ''
			documentation: ''
			insert_text: name_without_prefix
			insert_text_format: .plain_text
		})
	}
}
