module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct PureBlockStatementCompletionProvider {}

fn (k &PureBlockStatementCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent_nth(2) or { return false }
	if parent.node.type_name != .simple_statement {
		return false
	}
	return true
}

fn (mut k PureBlockStatementCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'defer { ... }'
		kind: .keyword
		insert_text: 'defer {\n\t$0\n}'
		insert_text_format: .snippet
		insert_text_mode: .adjust_indentation
	})
}
