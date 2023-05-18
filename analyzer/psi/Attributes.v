module psi

pub struct Attributes {
	PsiElementImpl
}

fn (_ &Attributes) stub() {}

pub fn (n Attributes) attributes() []PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			stubs := stub.get_children_by_type(.attribute)
			mut attrs := []PsiElement{cap: stubs.len}
			for attr_stub in stubs {
				attrs << attr_stub.get_psi() or { continue }
			}
			return attrs
		}
	}

	return n.find_children_by_type(.attribute)
}
