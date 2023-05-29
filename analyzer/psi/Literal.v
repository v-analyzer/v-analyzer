module psi

import analyzer.psi.types

pub struct Literal {
	PsiElementImpl
}

fn (_ &Literal) expr() {}

fn (n &Literal) get_type() types.Type {
	return infer_type(n)
}
