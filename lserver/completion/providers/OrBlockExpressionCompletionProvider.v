module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct OrBlockExpressionCompletionProvider {}

fn (k &OrBlockExpressionCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut k OrBlockExpressionCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'or { ... }'
		kind: .keyword
		insert_text: 'or { $0 }'
		insert_text_format: .snippet
	})

	result.add_element(lsp.CompletionItem{
		label: 'or { panic(err) }'
		kind: .keyword
		insert_text: 'or { panic(err) }'
	})
}
