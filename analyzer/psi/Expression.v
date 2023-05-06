module psi

pub interface Expression {
	PsiTypedElement
	expr() // dummy method to mark struct as Expression
}
