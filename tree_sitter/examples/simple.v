module main

import tree_sitter
import tree_sitter_v as v
import analyzer.structures.ropes

fn main() {
	mut p := tree_sitter.new_parser[v.NodeType](v.type_factory)
	p.set_language(v.language)

	code := 'fn main() {}'
	rope := ropes.new(code)
	tree := p.parse_string(source: code)
	root := tree.root_node()

	println(root)

	fc := root.first_child()?

	if fc.type_name == .function_declaration {
		if name_node := fc.child_by_field_name('name') {
			println('Found function: ${name_node.text(rope)}')
			println('Position: ${name_node.range()}')
			println('Line: ${name_node.start_point().row}')
		}
	}
}
