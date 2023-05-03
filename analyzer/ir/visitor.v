module ir

// Visitor is the interface that describes a visitor to an IR node.
// The visit method is called for each node in the IR tree. If the
// visit method returns true, the children of the node are visited.
// Otherwise, the children are not visited.
pub interface Visitor {
mut:
	visit(node Node) bool
}
