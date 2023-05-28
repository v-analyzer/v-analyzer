module providers

import analyzer.psi
import lserver.completion
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

fn (k &AttributesCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent_nth(2) or { return false }
	if parent.node.type_name != .value_attribute {
		return false
	}
	return true
}

fn (mut k AttributesCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
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
			insert_text: "${attribute}: '$1'$1"
			insert_text_format: .snippet
		})
	}
}
