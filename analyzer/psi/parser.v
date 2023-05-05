module psi

import tree_sitter
import tree_sitter_v as v
import analyzer.structures.ropes

pub fn parse_code(code string) PsiFileImpl {
	rope := ropes.new(code)
	mut parser := tree_sitter.new_parser[v.NodeType](v.language, v.type_factory)
	tree := parser.parse_string(source: code, tree: unsafe { nil })
	return new_psi_file(AstNode(tree.root_node()), rope)
}
