module psi

import tree_sitter_v as v

pub fn (node AstNode) parent_of_type(typ v.NodeType) ?AstNode {
	mut res := node
	for {
		res = res.parent()?
		if res.type_name == typ {
			return res
		}
	}

	return none
}
