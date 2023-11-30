module psi

pub struct InterfaceFieldScope {
	PsiElementImpl
}

pub fn (n InterfaceFieldScope) is_mutable() bool {
	text := n.get_text()
	return text.contains('mut')
}

fn (_ &InterfaceFieldScope) stub() {}
