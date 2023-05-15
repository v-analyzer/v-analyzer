module psi

import tree_sitter
import tree_sitter_v as v

pub type ID = int

pub type AstNode = tree_sitter.Node[v.NodeType]

pub interface PsiElement {
	id ID // базовый узел из Tree Sitter
	node AstNode // базовый узел из Tree Sitter
	containing_file &PsiFileImpl // файл, в котором находится узел
	stub_id StubId
	element_type() v.NodeType
	node() AstNode // базовый узел из Tree Sitter
	containing_file() &PsiFileImpl // файл, в котором находится узел
	is_equal(other PsiElement) bool
	// find_element_at возвращает узел, находящийся в указанной позиции относительно начала узла.
	// Если узел не найден, возвращается none.
	find_element_at(offset u32) ?PsiElement
	find_reference_at(offset u32) ?PsiElement
	// parent возвращает родительский узел.
	// Если узел является корневым, возвращается none.
	parent() ?PsiElement
	// parent_nth возвращает родительский узел, находящийся на указанном уровне вложенности.
	// Если такого узла не существует, возвращается none.
	parent_nth(depth int) ?PsiElement
	// parent_of_type возвращает родительский узел с указанным типом.
	// Если такого узла не существует, возвращается none.
	parent_of_type(typ v.NodeType) ?PsiElement
	// parent_of_type_or_self возвращает родительский узел с указанным типом или сам узел,
	// если его тип совпадает с указанным.
	// Если такого узла не существует, возвращается none.
	parent_of_type_or_self(typ v.NodeType) ?PsiElement
	// children возвращает все дочерние узлы.
	children() []PsiElement
	// first_child возвращает первый дочерний узел.
	// Если узел не имеет дочерних узлов, возвращается none.
	first_child() ?PsiElement
	// last_child возвращает последний дочерний узел.
	// Если узел не имеет дочерних узлов, возвращается none.
	last_child() ?PsiElement
	// next_sibling возвращает следующий узел, находящийся на том же уровне вложенности.
	// Если узел является последним дочерним узлом, возвращается none.
	next_sibling() ?PsiElement
	prev_sibling() ?PsiElement
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
	text_range() TextRange
}
