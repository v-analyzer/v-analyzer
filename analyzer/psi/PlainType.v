module psi

pub struct PlainType {
	PsiElementImpl
}

fn (n &PlainType) name() string {
	return ''
}

fn (n &PlainType) stub() ?&StubBase {
	return none
}
