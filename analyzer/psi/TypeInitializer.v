module psi

import analyzer.psi.types

pub struct TypeInitializer {
	PsiElementImpl
}

fn (_ &TypeInitializer) expr() {}

fn (n &TypeInitializer) get_type() types.Type {
	return infer_type(n)
}
