module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct NilKeywordCompletionProvider {}

fn (k &NilKeywordCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut k NilKeywordCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	inside_unsafe := ctx.element.inside(.unsafe_expression)

	insert_text := if !inside_unsafe {
		'unsafe { nil }'
	} else {
		'nil'
	}

	result.add_element(lsp.CompletionItem{
		label: 'nil'
		kind: .keyword
		insert_text: insert_text
	})
}
