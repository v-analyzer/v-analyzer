module psi

pub struct FunctionOrMethodDeclaration {
	PsiElementImpl
}

pub fn (f FunctionOrMethodDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier) or { return none }
}

pub fn (f FunctionOrMethodDeclaration) signature() ?&Signature {
	signature := f.find_child_by_type(.signature) or { return none }
	if signature is Signature {
		return signature
	}
	return none
}

pub fn (f FunctionOrMethodDeclaration) name() string {
	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f FunctionOrMethodDeclaration) doc_comment() string {
	return extract_doc_comment(f)
}

pub fn (f FunctionOrMethodDeclaration) receiver() ?&Receiver {
	element := f.find_child_by_type(.receiver) or { return none }
	if element is Receiver {
		return element
	}
	return none
}
