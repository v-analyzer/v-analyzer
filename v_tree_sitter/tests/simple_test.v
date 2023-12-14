module tests

import v_tree_sitter.tree_sitter
import tree_sitter_v

fn test_simple() {
	mut p := tree_sitter.new_parser[tree_sitter_v.NodeType](tree_sitter_v.type_factory)
	p.set_language(tree_sitter_v.language)

	code := 'fn main() {}'
	tree := p.parse_string(source: code)
	root := tree.root_node()

	println(root)

	fc := root.first_child()?

	if fc.type_name == .function_declaration {
		if name_node := fc.child_by_field_name('name') {
			assert name_node.text(code) == 'main'
			assert name_node.range().start_point.row == 0
			assert name_node.range().start_point.column == 3
			assert name_node.range().end_point.row == 0
			assert name_node.range().end_point.column == 7
		} else {
			assert false, 'name node not found'
		}
	} else {
		assert false, 'function declaration not found'
	}
}
