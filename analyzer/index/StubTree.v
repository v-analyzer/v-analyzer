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

pub fn (tree &StubTree) print() {
	tree.print_stub(tree.root, 0)
}

pub fn (tree &StubTree) print_stub(stub psi.StubElement, indent int) {
	for i := 0; i < indent; i++ {
		print('  ')
	}
	println(stub.stub_type().str() + ' (text: ' + stub.text() + ')')
	for child in stub.children_stubs() {
		tree.print_stub(child, indent + 1)
	}
}

pub fn build_stub_tree(file &psi.PsiFileImpl) &StubTree {
	root := file.root()
	stub_root := psi.new_root_stub(file.path())

	build_stub_tree_for_node(root, stub_root, false)

	return &StubTree{
		root: stub_root
	}
}

pub fn build_stub_tree_for_node(node psi.PsiElement, parent psi.StubBase, build_for_all_children bool) {
	element_type := psi.StubbedElementType{}

	if node is psi.StubBasedPsiElement || psi.node_is_type(node) || build_for_all_children {
		if stub := element_type.create_stub(node as psi.PsiElement, parent) {
			is_qualified_type := node is psi.QualifiedType
			for child in (node as psi.PsiElement).children() {
				build_stub_tree_for_node(child, stub, build_for_all_children || is_qualified_type)
			}
		}
		return
	}

	for child in node.children() {
		build_stub_tree_for_node(child, parent, false)
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
