module psi

pub struct ModuleClause {
	PsiElementImpl
}

pub fn (n ModuleClause) name() string {
	identifier := n.find_child_by_type(.module_identifier) or { return '' }
	return identifier.get_text()
}
