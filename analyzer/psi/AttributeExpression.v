module psi

pub struct AttributeExpression {
	PsiElementImpl
}

pub fn (n &AttributeExpression) value() string {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			if first_child := stub.first_child() {
				return first_child.text()
			}
			return ''
		}
	}

	if first_child := n.first_child() {
		if first_child is ValueAttribute {
			return first_child.value()
		}
	}

	return ''
}

fn (_ &AttributeExpression) stub() {}
