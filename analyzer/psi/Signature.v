module psi

import analyzer.psi.types

pub struct Signature {
	PsiElementImpl
}

pub fn (s &Signature) get_type() types.Type {
	return infer_type(s)
}

pub fn (n Signature) parameters() []PsiElement {
	list := n.find_child_by_type_or_stub(.parameter_list) or { return [] }
	parameters := list.find_children_by_type_or_stub(.parameter_declaration)
	return parameters
}

pub fn (n Signature) result() ?PsiElement {
	last := n.last_child_or_stub()?
	if last is PlainType {
		return last
	}
	return none
}

fn (_ &Signature) stub() {}
