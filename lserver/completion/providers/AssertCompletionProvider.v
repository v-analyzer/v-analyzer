module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct AssertCompletionProvider {}

fn (_ &AssertCompletionProvider) is_available(context psi.PsiElement) bool {
	if !context.containing_file.is_test_file() {
		return false
	}

	parent := context.parent_nth(2) or { return false }
	if parent.node.type_name != .simple_statement && parent.node.type_name != .assert_statement {
		return false
	}
	return true
}

fn (mut _ AssertCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'assert expr'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: 'assert \${1:expr}'
	})

	result.add_element(lsp.CompletionItem{
		label: 'assert expr, message'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: "assert \${1:expr}, '\${2:message}'$0"
	})
}
