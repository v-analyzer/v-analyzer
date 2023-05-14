module psi

pub struct ModuleClause {
	PsiElementImpl
}

fn (n &ModuleClause) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &ModuleClause) identifier_text_range() TextRange {
	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n ModuleClause) name() string {
	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}
