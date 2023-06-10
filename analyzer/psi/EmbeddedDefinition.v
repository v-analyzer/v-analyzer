module psi

import analyzer.psi.types

pub struct EmbeddedDefinition {
	PsiElementImpl
}

pub fn (n &EmbeddedDefinition) get_type() types.Type {
	ref_expression := n.find_child_by_type_or_stub(.type_reference_expression) or {
		return types.unknown_type
	}
	return infer_type(ref_expression)
}

fn (n &EmbeddedDefinition) stub() {}
