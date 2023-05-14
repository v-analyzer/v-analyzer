module psi

pub interface PsiNamedElement {
	identifier_text_range() TextRange
	identifier() ?PsiElement
	name() string
}
