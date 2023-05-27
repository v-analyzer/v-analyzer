module completion

import analyzer.psi

pub interface CompletionProvider {
	is_available(context psi.PsiElement) bool
mut:
	add_completion(ctx CompletionContext, mut result CompletionResultSet)
}
