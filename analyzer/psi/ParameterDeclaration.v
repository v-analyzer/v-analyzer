module psi

pub struct ParameterDeclaration {
	PsiElementImpl
}

fn (n &ParameterDeclaration) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

fn (n &ParameterDeclaration) name() string {
	if id := n.identifier() {
		return id.get_text()
	}

	return ''
}
