module psi

pub struct StructFieldScope {
	PsiElementImpl
}

fn (n &StructFieldScope) name() string {
	return ''
}

fn (n &StructFieldScope) stub() ?&StubBase {
	return none
}

pub fn (n StructFieldScope) is_mutable_public() (bool, bool) {
	text := n.get_text()
	return text.contains('mut'), text.contains('pub')
}
