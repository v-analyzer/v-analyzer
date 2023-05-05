module psi

// inspect traverses an AST in depth-first order: It starts by calling
// `cb(node)`; node must not be `nil`. If call returns `true`, `inspect` invokes `cb`
// recursively for each of the non-nil children of node. Otherwise, `inspect` skips
// the children of node.
//
// Example:
// ```
// inspect(root, fn (node PsiElement) bool {
//   match node {
//     psi.FunctionDeclaration {
//       println('function ${node.name()}')
//     }
//     else {}
//   }
//   return true
// })
pub fn inspect(node PsiElement, cb fn (PsiElement) bool) {
	inspector := Inspector{
		cb: cb
	}
	node.accept(inspector)
}

struct Inspector {
	RecursiveVisitorBase
	cb fn (PsiElement) bool
}

fn (i &Inspector) visit_element_impl(element PsiElement) bool {
	return i.cb(element)
}
