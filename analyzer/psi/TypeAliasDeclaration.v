module psi

pub struct TypeAliasDeclaration {
	PsiElementImpl
}

pub fn (f TypeAliasDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier) or { return none }
}

pub fn (f TypeAliasDeclaration) name() string {
	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}
