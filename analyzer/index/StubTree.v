module index

import analyzer.psi

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
