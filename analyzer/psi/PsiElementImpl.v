module psi

import tree_sitter
import tree_sitter_v as v

pub struct PsiElementImpl {
pub:
	id          ID
	node        AstNode // базовый узел из Tree Sitter
	source_text &tree_sitter.SourceText
}

fn new_psi_node(id ID, text &tree_sitter.SourceText, node AstNode) PsiElementImpl {
	return PsiElementImpl{
		id: id
		node: node
		source_text: unsafe { text }
	}
}

pub fn (n PsiElementImpl) accept(visitor PsiElementVisitor) {
	visitor.visit_element(n)
}

pub fn (n PsiElementImpl) find_element_at(offset u32) ?PsiElement {
	child := n.node.first_leaf_element_at(offset) or { return none }
	return create_element(child, n.source_text)
}

pub fn (n PsiElementImpl) parent() ?PsiElement {
	parent := n.node.parent() or { return none }
	return create_element(parent, n.source_text)
}

pub fn (n PsiElementImpl) children() []PsiElement {
	mut result := []PsiElement{}
	mut child := n.node.first_child() or { return [] }
	for {
		result << create_element(child, n.source_text)
		child = child.next_sibling() or { break }
	}
	return result
}

pub fn (n PsiElementImpl) first_child() ?PsiElement {
	child := n.node.first_child() or { return none }
	return create_element(child, n.source_text)
}

pub fn (n PsiElementImpl) next_sibling() ?PsiElement {
	sibling := n.node.next_sibling() or { return none }
	return create_element(sibling, n.source_text)
}

pub fn (n PsiElementImpl) find_child_by_type(typ v.NodeType) ?PsiElement {
	ast_node := n.node.first_node_by_type(typ) or { return none }
	return create_element(ast_node, n.source_text)
}

pub fn (n PsiElementImpl) find_children_by_type(typ v.NodeType) []PsiElement {
	mut result := []PsiElement{}
	mut child := n.node.first_child() or { return [] }
	for {
		if child.type_name == typ {
			result << create_element(child, n.source_text)
		}
		child = child.next_sibling() or { break }
	}
	return result
}

pub fn (n PsiElementImpl) get_text() string {
	return n.node.text(n.source_text)
}
