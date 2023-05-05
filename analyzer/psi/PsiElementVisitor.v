module psi

pub interface PsiElementVisitor {
	visit_element(element PsiElement)
	visit_element_impl(element PsiElement)
}
