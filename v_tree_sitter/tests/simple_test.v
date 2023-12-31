// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
