module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct InitsCompletionProvider {}

fn (_ &InitsCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut _ InitsCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'chan'
		kind: .snippet
		detail: ''
		insert_text: 'chan \${1:int}{}$0'
		insert_text_format: .snippet
	})

	result.add_element(lsp.CompletionItem{
		label: 'map'
		kind: .snippet
		detail: ''
		insert_text: 'map[\${1:string}]\${2:int}{}$0'
		insert_text_format: .snippet
	})

	result.add_element(lsp.CompletionItem{
		label: 'thread'
		kind: .snippet
		detail: ''
		insert_text: 'thread \${1:int}{}$0'
		insert_text_format: .snippet
	})
}
