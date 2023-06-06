module psi

import analyzer.psi

pub interface GenericParametersOwner {
	generic_parameters() ?&psi.GenericParameters
}
