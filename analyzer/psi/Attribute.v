module psi

pub struct Attribute {
	PsiElementImpl
}

fn (n &Attribute) name() string {
	return ''
}

fn (n &Attribute) stub() ?&StubBase {
	return none
}

pub fn (n Attribute) expressions() []PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			stubs := stub.get_children_by_type(.attribute_expression)
			mut attr_expressions := []PsiElement{cap: stubs.len}
			for attr_stub in stubs {
				attr_expressions << attr_stub.get_psi() or { continue }
			}
			return attr_expressions
		}
	}

	return n.find_children_by_type(.attribute_expression)
}

pub fn (n Attribute) keys() []string {
	expressions := n.expressions()
	if expressions.len == 0 {
		return []
	}

	return expressions.map(fn (expr PsiElement) string {
		if expr is AttributeExpression {
			return expr.value()
		}

		return ''
	}).filter(it != '')
}
