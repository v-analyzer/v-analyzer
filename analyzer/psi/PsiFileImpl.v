module psi

import tree_sitter

pub struct PsiFileImpl {
	path        string
	source_text &tree_sitter.SourceText
mut:
	root PsiElement
}

pub fn new_psi_file(path string, root AstNode, source_text &tree_sitter.SourceText) &PsiFileImpl {
	mut file := &PsiFileImpl{
		path: path
		source_text: unsafe { source_text }
	}
	file.root = create_element(root, file)
	return file
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
	if element is ReferenceExpressionBase {
		return element as PsiElement
	}
	if element is Identifier {
		parent := element.parent()?
		if parent is ReferenceExpressionBase {
			return parent as PsiElement
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
