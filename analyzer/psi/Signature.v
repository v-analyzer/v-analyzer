module psi

import analyzer.psi.types

pub struct Signature {
	PsiElementImpl
}

fn (s &Signature) get_type() types.Type {
	params := s.parameters()
	param_types := params.map(fn (it PsiElement) types.Type {
		if it is PsiTypedElement {
			return it.get_type()
		}
		return types.unknown_type
	})
	result := TypeInferer{}.convert_type(s.result())

	return types.new_function_type(param_types, result)
}

pub fn (n Signature) parameters() []PsiElement {
	list := n.find_child_by_type_or_stub(.parameter_list) or { return [] }
	parameters := list.find_children_by_type_or_stub(.parameter_declaration)
	return parameters.filter(it is ParameterDeclaration)
}

pub fn (n Signature) result() ?PsiElement {
	last := n.last_child_or_stub()?
	if last is PlainType {
		return last
	}
	return none
}

fn (_ &Signature) stub() {}
