module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct KeywordsCompletionProvider {}

fn (k &KeywordsCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut k KeywordsCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	k.no_space_keywords([
		'none',
		'true',
		'false',
		'static',
	], mut result)
}

fn (mut k KeywordsCompletionProvider) no_space_keywords(keywords []string, mut result completion.CompletionResultSet) {
	for keyword in keywords {
		result.add_element(lsp.CompletionItem{
			label: keyword
			kind: .keyword
			insert_text: keyword
		})
	}
}
