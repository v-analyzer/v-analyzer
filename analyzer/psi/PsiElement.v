module psi

import tree_sitter
import tree_sitter_v as v

pub type ID = int

pub type AstNode = tree_sitter.Node[v.NodeType]

pub interface PsiElement {
	id ID // базовый узел из Tree Sitter
	node AstNode // базовый узел из Tree Sitter
	source_text &tree_sitter.SourceText // исходный код, из которого было получено дерево
	// find_element_at возвращает узел, находящийся в указанной позиции относительно начала узла.
	// Если узел не найден, возвращается none.
	find_element_at(offset u32) ?PsiElement
	// parent возвращает родительский узел.
	// Если узел является корневым, возвращается none.
	parent() ?PsiElement
	// children возвращает все дочерние узлы.
	children() []PsiElement
	// first_child возвращает первый дочерний узел.
	first_child() ?PsiElement
	// next_sibling возвращает следующий узел, находящийся на том же уровне вложенности.
	// Если узел является последним дочерним узлом, возвращается none.
	next_sibling() ?PsiElement
	// find_child_by_type возвращает первый дочерний узел с указанным типом.
	// Если такой узел не найден, возвращается none.
	find_child_by_type(typ v.NodeType) ?PsiElement
	// find_children_by_type возвращает все дочерние узлы с указанным типом.
	// Если такие узлы не найдены, возвращается пустой массив.
	find_children_by_type(typ v.NodeType) []PsiElement
	// get_text возвращает текст узла.
	get_text() string
	// accept передает элемент в переданный visitor.
	accept(visitor PsiElementVisitor)
	// accept_mut передает элемент в переданный visitor.
	// В отличии от accept, этот метод использует visitor который может
	// мутировать свое состояние.
	accept_mut(mut visitor MutablePsiElementVisitor)
}
