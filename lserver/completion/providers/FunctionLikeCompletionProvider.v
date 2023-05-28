module providers

import analyzer.psi
import lserver.completion
import lsp

pub const function_like_keywords = [
	'dump',
	'sizeof',
	'typeof',
	'isreftype',
	'__offsetof',
]

pub struct FunctionLikeCompletionProvider {}

fn (k &FunctionLikeCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut k FunctionLikeCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	for keyword in providers.function_like_keywords {
		result.add_element(lsp.CompletionItem{
			label: '${keyword}()'
			kind: .keyword
			insert_text: '${keyword}($1)$0'
			insert_text_format: .snippet
		})
	}
}
