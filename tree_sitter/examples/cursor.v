module main

import tree_sitter
import tree_sitter_v as v
import analyzer.structures.ropes

fn main() {
	mut p := tree_sitter.new_parser[v.NodeType](v.type_factory)
	p.set_language(v.language)

	code := '
fn foo() int {
	return 1
}
'.trim_indent()

	rope := ropes.new(code)
	tree := p.parse_string(source: code)
	root := tree.root_node()

	mut cursor := root.tree_cursor()
	cursor.to_first_child() // go to all the children of the root node
	cursor.to_first_child() // go to the first child of the function node

	for {
		node := cursor.current_node() or { break }

		println('Node "${node.type_name}" with text: ' + node.text(rope))

		if !cursor.next() {
			break
		}
	}
}
