module psi

import analyzer.psi.types

pub struct ParameterDeclaration {
	PsiElementImpl
}

fn (p &ParameterDeclaration) stub() {}

pub fn (p &ParameterDeclaration) get_type() types.Type {
	type_ := TypeInferer{}.infer_from_plain_type(p)
	if _ := p.find_child_by_name('variadic') {
		return types.new_array_type(type_)
	}
	return type_
}

pub fn (p &ParameterDeclaration) identifier() ?PsiElement {
	return p.find_child_by_type(.identifier)
}

pub fn (p &ParameterDeclaration) identifier_text_range() TextRange {
	if p.stub_id != non_stubbed_element {
		if stub := p.stubs_list.get_stub(p.stub_id) {
			return stub.text_range
		}
	}

	identifier := p.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (p &ParameterDeclaration) name() string {
	if p.stub_id != non_stubbed_element {
		if stub := p.stubs_list.get_stub(p.stub_id) {
			return stub.name
		}
	}

	identifier := p.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (p &ParameterDeclaration) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := p.find_child_by_type(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}

pub fn (p &ParameterDeclaration) is_mutable() bool {
	mods := p.mutability_modifiers() or { return false }
	return mods.is_mutable()
}
