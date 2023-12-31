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
import analyzer.psi.types
import analyzer.lang
import lsp

pub struct ReturnCompletionProvider {}

fn (_ &ReturnCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_statement && !ctx.after_at
}

fn (mut _ ReturnCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	element := ctx.element

	parent_function := element.parent_of_any_type(.function_declaration, .function_literal) or {
		return
	}
	signature := if parent_function is psi.SignatureOwner {
		parent_function.signature() or { return }
	} else {
		return
	}

	function_type := signature.get_type()
	if function_type is types.FunctionType {
		has_result_type := !function_type.no_result
		result_type := function_type.result
		if result_type is types.PrimitiveType {
			if result_type.name == 'bool' {
				result.add_element(lsp.CompletionItem{
					label: 'return true'
					kind: .text
				})
				result.add_element(lsp.CompletionItem{
					label: 'return false'
					kind: .text
				})
			}
		}

		if has_result_type {
			zero_value := lang.get_zero_value_for(result_type)
			result.add_element(lsp.CompletionItem{
				label: 'return ${zero_value}'
				kind: .text
			})
		}

		label := if !has_result_type {
			'return'
		} else {
			'return '
		}

		result.add_element(lsp.CompletionItem{
			label: label
			kind: .text
		})
	}
}
