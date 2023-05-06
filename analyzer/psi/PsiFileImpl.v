module psi

import tree_sitter

pub struct PsiFileImpl {
	path        string
	source_text &tree_sitter.SourceText
	root        PsiElement
}

pub fn new_psi_file(path string, root AstNode, source_text &tree_sitter.SourceText) PsiFileImpl {
	return PsiFileImpl{
		path: path
		root: create_element(root, source_text)
		source_text: unsafe { source_text }
	}
}

pub fn (p &PsiFileImpl) path() string {
	return p.path
}

pub fn (p &PsiFileImpl) text() &tree_sitter.SourceText {
	return p.source_text
}

pub fn (p &PsiFileImpl) root() PsiElement {
	return p.root
}

pub fn (p &PsiFileImpl) find_element_at(offset u32) ?PsiElement {
	return p.root.find_element_at(offset)
}

pub fn (p &PsiFileImpl) find_reference_at(offset u32) ?PsiElement {
	element := p.find_element_at(offset)?
	if element is ReferenceExpression {
		return element
	}
	if element is Identifier {
		parent := element.parent()?
		if parent is ReferenceExpression {
			return parent
		}
	}
	return none
}

pub fn (p &PsiFileImpl) module_name() ?string {
	module_clause := p.root().find_child_by_type(.module_clause)?

	if module_clause is ModuleClause {
		return module_clause.name()
	}

	return none
}

pub fn (p &PsiFileImpl) process_declarations(mut processor PsiScopeProcessor) bool {
	children := p.root.children()
	for child in children {
		if child is PsiNamedElement {
			if !processor.execute(child as PsiElement) {
				return false
			}
		}
	}

	return true
}
