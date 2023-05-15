module psi

pub struct Signature {
	PsiElementImpl
}

fn (n &Signature) name() string {
	return ''
}

fn (n &Signature) stub() ?&StubBase {
	return none
}

pub fn (n Signature) parameters() []PsiElement {
	list := n.find_child_by_type(.parameter_list) or { return [] }
	parameters := list.find_children_by_type(.parameter_declaration)
	return parameters.filter(it is ParameterDeclaration)
}
