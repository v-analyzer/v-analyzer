module providers

import analyzer.psi
import lserver.completion
import analyzer.psi.types
import lsp

pub struct ReturnCompletionProvider {}

fn (_ &ReturnCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_statement
}

fn (mut _ ReturnCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	element := ctx.element

	parent_function := element.parent_of_type(.function_declaration) or { return }
	signature := if parent_function is psi.SignatureOwner {
		parent_function.signature() or { return }
	} else {
		return
	}

	function_type := signature.get_type()
	if function_type is types.FunctionType {
		has_result_type := function_type.no_result
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

		label := if has_result_type {
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
