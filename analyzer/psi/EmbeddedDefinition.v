module psi

import analyzer.psi.types

pub struct EmbeddedDefinition {
	PsiElementImpl
}

pub fn (n &EmbeddedDefinition) get_type() types.Type {
	if qualified_type := n.find_child_by_type_or_stub(.qualified_type) {
		mut visited := map[string]types.Type{}
		return TypeInferer{}.convert_type_inner(qualified_type, mut visited)
	}
	ref_expression := n.find_child_by_type_or_stub(.type_reference_expression) or {
		return types.unknown_type
	}
	return infer_type(ref_expression)
}

fn (n &EmbeddedDefinition) stub() {}
