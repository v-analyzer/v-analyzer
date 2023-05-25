module psi

import time
import tree_sitter_v as v
import analyzer.parser
import v_tree_sitter.tree_sitter
import analyzer.structures.ropes

[heap]
pub struct PsiFileImpl {
pub:
	path string
pub mut:
	tree        &tree_sitter.Tree[v.NodeType] = unsafe { nil }
	source_text string
	root        PsiElement
}

pub fn new_psi_file(path string, tree &tree_sitter.Tree[v.NodeType], source_text string) &PsiFileImpl {
	mut file := &PsiFileImpl{
		path: path
		tree: unsafe { tree }
		source_text: source_text
	}
	file.root = create_element(AstNode(tree.root_node()), file)
	return file
}

pub fn new_stub_psi_file(path string) &PsiFileImpl {
	return &PsiFileImpl{
		path: path
		tree: unsafe { nil }
		source_text: unsafe { nil }
	}
}

pub fn (p &PsiFileImpl) is_stub_based() bool {
	return isnil(p.tree)
}

pub fn (mut p PsiFileImpl) reparse(new_code string) {
	now := time.now()
	// TODO: по каким то причинам если передавать старое дерево затем попытка получить
	// текст узла дает текст по неправильному смещению
	res := parser.parse_code_with_tree(new_code, unsafe { nil })
	p.tree = res.tree
	p.source_text = res.source_text
	p.root = create_element(AstNode(res.tree.root_node()), p)
	println('reparse time: ${time.since(now)}')
}

pub fn (p &PsiFileImpl) path() string {
	return p.path
}

pub fn (p &PsiFileImpl) text() string {
	return p.source_text
}

pub fn (p &PsiFileImpl) root() PsiElement {
	return p.root
}

pub fn (p &PsiFileImpl) find_element_at(offset u32) ?PsiElement {
	return p.root.find_element_at(offset)
}

pub fn (p &PsiFileImpl) find_reference_at(offset u32) ?ReferenceExpressionBase {
	element := p.find_element_at(offset)?
	if element is ReferenceExpressionBase {
		return element
	}
	if element is Identifier {
		parent := element.parent()?
		if parent is ReferenceExpressionBase {
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
		if child is ConstantDeclaration {
			for constant in child.constants() {
				if constant is PsiNamedElement {
					if !processor.execute(constant as PsiElement) {
						return false
					}
				}
			}
		}
	}

	return true
}
