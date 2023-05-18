module index

import analyzer.psi

// StubTree представляет дерево stub-ов для файла.
// Это дерево, в отличии от AST, содержит вершины, данные которых
// мы хотим сериализовать для ускорения запуска проекта.
// Такие вершины реализуют интерфейс `psi.StubBasedPsiElement`.
//
// В отличии от AST, StubTree довольно маленькие деревья, благодаря
// чему их и можно легко сохранять и полностью загружать в оперативную
// память не занимая очень много места.
//
// С помощью StubTree также строятся стабовые индексы, которые позволяют
// быстро находить нужные элементы в проекте.
// See `StubbedElementType.index_stub()`.
pub struct StubTree {
	root &psi.StubBase
}

pub fn build_stub_tree(file &psi.PsiFileImpl) &StubTree {
	root := file.root()
	stub_root := psi.new_root_stub(file.path())

	build_stub_tree_for_node(root, stub_root)

	return &StubTree{
		root: stub_root
	}
}

pub fn build_stub_tree_for_node(node psi.PsiElement, parent psi.StubBase) {
	element_type := psi.StubbedElementType{}

	if node is psi.StubBasedPsiElement {
		if stub := element_type.create_stub(node as psi.PsiElement, parent) {
			for child in (node as psi.PsiElement).children() {
				build_stub_tree_for_node(child, stub)
			}
		}
		return
	}

	for child in node.children() {
		build_stub_tree_for_node(child, parent)
	}
}

struct NodeInfo {
	node   psi.PsiElement
	parent &psi.StubBase
}

[direct_array_access]
pub fn build_stub_tree_iterative(file &psi.PsiFileImpl, mut nodes []NodeInfo) &StubTree {
	root := file.root()
	stub_root := psi.new_root_stub(file.path())

	nodes = nodes[..0]
	nodes << NodeInfo{
		node: root
		parent: stub_root
	}

	element_type := psi.StubbedElementType{}

	for nodes.len > 0 {
		node := nodes.pop()
		this_parent_stub := node.parent

		parent_stub := if node.node is psi.StubBasedPsiElement {
			if stub := element_type.create_stub(node.node as psi.PsiElement, this_parent_stub) {
				stub
			} else {
				this_parent_stub
			}
		} else {
			this_parent_stub
		}

		for child in node.node.children() {
			nodes << NodeInfo{
				node: child
				parent: parent_stub
			}
		}
	}
	return &StubTree{
		root: stub_root
	}
}
