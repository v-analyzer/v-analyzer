module psi

pub interface ReferenceExpressionBase {
	Expression
	get_text() string
	text_range() TextRange
	name() string
	qualifier() ?PsiElement
	reference() PsiReference
	resolve() ?PsiElement
}
