module psi

pub struct ValueAttribute {
	PsiElementImpl
}

fn (n &ValueAttribute) name() string {
	return ''
}

fn (n &ValueAttribute) stub() ?&StubBase {
	return none
}

pub fn (n ValueAttribute) value() string {
	return n.get_text()
}
