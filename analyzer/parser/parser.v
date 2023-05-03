module parser

import tree_sitter_v as v
import tree_sitter
import os
import analyzer.ir
import analyzer.structures.ropes

// Source represent the possible types of V source code to parse.
type Source = []byte | string

// parse_file parses a V source file and returns the corresponding `ir.File` node.
// If the file could not be read, an error is returned.
// If the file was read successfully, but could not be parsed, the result
// is a partiall AST.
//
// Example:
// ```
// import parser
//
// fn main() {
//   mut file := parser.parse_file('foo.v') or {
//     eprintln('Error: could not parse file: ${err}')
//     return
//   }
//   println(file)
// }
// ```
pub fn parse_file(filename string) !&ir.File {
	mut file := os.read_file(filename) or {
		return error('could not read file ${filename}: ${err}')
	}
	return parse_source(file)
}

// parse_source parses a V code and returns the corresponding `ir.File` node.
// Unlike `parse_file`, `parse_source` uses the source directly, without reading it from a file.
// See `parser.Source` for the possible types of `source`.
//
// Example:
// ```
// import parser
//
// fn main() {
//   mut file := parser.parse_source('fn main() { println("Hello, World!") }') or {
//     eprintln('Error: could not parse source: ${err}')
//     return
//   }
//   println(file)
// }
// ```
pub fn parse_source(source Source) !&ir.File {
	code := match source {
		string {
			source
		}
		[]byte {
			source.str()
		}
	}
	return parse_code(code)
}

// parse_code parses a V code and returns the corresponding ir.File node.
// Unlike `parse_file` and `parse_source`, `parse_code` don't return an error since
// the source is always valid.
pub fn parse_code(code string) &ir.File {
	file, _ := parse_code_with_tree(code, unsafe { nil })
	return file
}

// parse_code_with_tree parses a V code and returns the corresponding `ir.File`
// node and inner tree object.
// This tree object can be used to reparse the code with a some changes. This
// is useful for incremental parsing.
//
// Unlike `parse_file` and `parse_source`, `parse_code` don't return an error since
// the source is always valid.
//
// Example:
// ```
// import parser
//
// fn main() {
//   code := 'fn main() { println("Hello, World!") }'
//   file, tree := parser.parse_code_with_tree(code, unsafe { nil })
//   println(file)
//   // some changes in code
//   code2 := 'fn foo() { println("Hello, World!") }'
//   file2, _ = parser.parse_code_with_tree(code2, tree)
//   println(file2)
// }
pub fn parse_code_with_tree(code string, old_tree &tree_sitter.Tree[v.NodeType]) (&ir.File, &tree_sitter.Tree[v.NodeType]) {
	rope := ropes.new(code)
	mut parser := tree_sitter.new_parser[v.NodeType](v.language, v.type_factory)
	raw_tree := if isnil(old_tree) { unsafe { nil } } else { old_tree.raw_tree }
	tree := parser.parse_string(source: code, tree: raw_tree)
	return ir.convert_file(tree, tree.root_node(), rope), tree
}
