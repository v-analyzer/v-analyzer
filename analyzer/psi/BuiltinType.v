module psi

pub struct BuiltinType {
	PsiElementImpl
}

fn (n &BuiltinType) name() string {
	return ''
}

fn (n &BuiltinType) stub() ?&StubBase {
	return none
}
