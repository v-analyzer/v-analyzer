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
import analyzer.psi
import loglib

pub fn (mut ls LanguageServer) signature_help(params lsp.SignatureHelpParams) ?lsp.SignatureHelp {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		loglib.with_fields({
			'offset': offset.str()
		}).warn('Cannot find element')
		return none
	}

	call := element.parent_of_type_or_self(.call_expression) or {
		loglib.with_fields({
			'offset': offset.str()
		}).warn('Cannot find call expression')
		return none
	}

	if call is psi.CallExpression {
		resolved := call.resolve() or {
			loglib.with_fields({
				'offset': offset.str()
			}).warn('Cannot resolve call expression for signature help')
			return none
		}

		if resolved is psi.FunctionOrMethodDeclaration {
			ctx := params.context
			active_parameter := call.parameter_index_on_offset(offset)

			if ctx.is_retrigger {
				mut help := ctx.active_signature_help
				help.active_parameter = active_parameter
				return help
			}

			signature := resolved.signature()?
			parameters := signature.parameters()

			mut param_infos := []lsp.ParameterInformation{}
			for parameter in parameters {
				param_infos << lsp.ParameterInformation{
					label: parameter.get_text()
				}
			}

			return lsp.SignatureHelp{
				active_parameter: active_parameter
				signatures: [
					lsp.SignatureInformation{
						label: 'fn ${resolved.name()}${signature.get_text()}'
						parameters: param_infos
					},
				]
			}
		}
	}

	return none
}
