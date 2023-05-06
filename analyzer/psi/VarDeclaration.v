module psi

pub struct VarDeclaration {
	PsiElementImpl
}

fn (n VarDeclaration) vars() []PsiElement {
	first_child := n.first_child() or { return [] }
	return first_child
		.children()
		.filter(it is ReferenceExpression || it is MutExpression)
		.map(fn (it PsiElement) PsiElement {
			if it is MutExpression {
				return it.last_child() or { return it }
			}
			return it
		})
}
