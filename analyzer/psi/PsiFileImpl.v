module psi

import tree_sitter
import tree_sitter_v as v
import analyzer.parser
import time

[heap]
pub struct PsiFileImpl {
	path string
mut:
	tree        &tree_sitter.Tree[v.NodeType]
	source_text &tree_sitter.SourceText
	root        PsiElement
}

pub fn new_psi_file(path string, tree &tree_sitter.Tree[v.NodeType], source_text &tree_sitter.SourceText) &PsiFileImpl {
	mut file := &PsiFileImpl{
		path: path
		tree: unsafe { tree }
		source_text: unsafe { source_text }
	}
	file.root = create_element(AstNode(tree.root_node()), file)
	return file
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

pub fn (p &PsiFileImpl) text() &tree_sitter.SourceText {
	return p.source_text
}

pub fn (p &PsiFileImpl) root() PsiElement {
	return p.root
}

pub fn (p &PsiFileImpl) find_most_depth_element_at(offset u32) ?PsiElement {
	abs_offset := p.root.node.start_byte() + offset
	mut inspector := FindAllElementsAtOffsetInspector{
		offset: abs_offset
	}
	p.root.accept_mut(mut inspector)
	if inspector.result.len == 0 {
		return none
	}
	return inspector.result.last()
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
