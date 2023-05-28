module psi

import tree_sitter_v as v

pub interface PsiNamedElement {
	parent_of_type(typ v.NodeType) ?PsiElement
	identifier_text_range() TextRange
	identifier() ?PsiElement
	name() string
	is_public() bool
}
