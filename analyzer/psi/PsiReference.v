module psi

pub interface PsiReference {
	element() PsiElement
	resolve_local() ?PsiElement
	resolve() ?PsiElement
}
