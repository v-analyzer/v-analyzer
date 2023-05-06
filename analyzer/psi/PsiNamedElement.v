module psi

pub interface PsiNamedElement {
	identifier() ?PsiElement
	name() string
}
