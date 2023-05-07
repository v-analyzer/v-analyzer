module psi

import analyzer.psi.types

pub struct TypeInferer {
}

pub fn (t &TypeInferer) infer_type(expr Expression) types.Type {
	if expr is Literal {
		return expr.get_type()
	}

	return types.unknown_type
}
