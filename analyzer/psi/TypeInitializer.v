module psi

import analyzer.psi.types

pub struct TypeInitializer {
	PsiElementImpl
}

fn (n &TypeInitializer) get_type() types.Type {
	return infer_type(n)
}
