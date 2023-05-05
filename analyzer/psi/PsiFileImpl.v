module psi

import tree_sitter

pub struct PsiFileImpl {
	source_text &tree_sitter.SourceText
	root        PsiElement
}

pub fn new_psi_file(root AstNode, source_text &tree_sitter.SourceText) PsiFileImpl {
	return PsiFileImpl{
		root: create_element(root, source_text)
		source_text: unsafe { source_text }
	}
}

pub fn (p &PsiFileImpl) text() &tree_sitter.SourceText {
	return p.source_text
}

pub fn (p &PsiFileImpl) root() PsiElement {
	return p.root
}

pub fn (p &PsiFileImpl) find_element_at(offset u32) ?PsiElement {
	node := p.root.node.first_leaf_element_at(offset)
	return create_element(node, p.source_text)
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
