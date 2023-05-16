module psi

import analyzer.psi.types

pub struct Receiver {
	PsiElementImpl
}

fn (r &Receiver) identifier_text_range() TextRange {
	if r.stub_id != non_stubbed_element {
		if stub := r.stubs_list.get_stub(r.stub_id) {
			return stub.text_range
		}
	}

	identifier := r.identifier() or { return TextRange{} }
	return identifier.text_range()
}

fn (r &Receiver) stub() ?&StubBase {
	return none
}

fn (r &Receiver) identifier() ?PsiElement {
	return r.find_child_by_type(.identifier)
}

pub fn (r &Receiver) name() string {
	identifier := r.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (r &Receiver) type_element() ?PsiElement {
	if r.stub_id != non_stubbed_element {
		if stub := r.stubs_list.get_stub(r.stub_id) {
			if receiver_stub := stub.get_child_by_type(.plain_type) {
				psi := receiver_stub.get_psi() or { return none }
				if psi is PlainType {
					return psi
				}
			}
			return none
		}
	}

	return r.find_child_by_type(.plain_type)
}

pub fn (r &Receiver) get_type() types.Type {
	inferer := TypeInferer{}
	return inferer.infer_from_plain_type(r)
}

pub fn (r &Receiver) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := r.find_child_by_type(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}

pub fn (r &Receiver) is_mutable() bool {
	mods := r.mutability_modifiers() or { return false }
	return mods.is_mutable()
}
