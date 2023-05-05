module psi

pub struct RecursiveVisitor {
}

fn (r &RecursiveVisitor) visit_element(element PsiElement) {
	r.visit_element_impl(element)
	mut child := element.first_child() or { return }
	for {
		child.accept(r)
		child = child.next_sibling() or { break }
	}
}

fn (r &RecursiveVisitor) visit_element_impl(element PsiElement) {
	println('visit ${element.node.type_name}')
}
