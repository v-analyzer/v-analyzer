module psi

pub struct TypeAliasDeclaration {
	PsiElementImpl
}

pub fn (a TypeAliasDeclaration) identifier() ?PsiElement {
	return a.find_child_by_type(.identifier) or { return none }
}

pub fn (a &TypeAliasDeclaration) identifier_text_range() TextRange {
	identifier := a.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (a TypeAliasDeclaration) name() string {
	identifier := a.identifier() or { return '' }
	return identifier.get_text()
}
