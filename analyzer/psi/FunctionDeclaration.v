module psi

pub struct FunctionDeclaration {
	PsiElementImpl
}

pub fn (f FunctionDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier) or { return none }
}

pub fn (f FunctionDeclaration) signature() ?&Signature {
	signature := f.find_child_by_type(.signature) or { return none }
	if signature is Signature {
		return signature
	}
	return none
}

pub fn (f FunctionDeclaration) name() string {
	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}
