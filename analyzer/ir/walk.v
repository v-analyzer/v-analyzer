module ir

struct Inspector {
	cb fn (Node) bool
}

fn (mut i Inspector) visit(node Node) bool {
	return i.cb(node)
}

// inspect traverses an AST in depth-first order: It starts by calling
// `cb(node)`; node must not be `nil`. If call returns `true`, `inspect` invokes `cb`
// recursively for each of the non-nil children of node. Otherwise, `inspect` skips
// the children of node.
//
// Example:
// ```
// inspect(root, fn (node Node) bool {
//   match node {
//     ir.FunctionDelcaration {
//       println('function ${node.name.value}')
//     }
//     else {}
//   }
//   return true
// })
pub fn inspect(node Node, cb fn (Node) bool) {
	mut inspector := Inspector{
		cb: cb
	}
	node.accept(mut inspector)
}
