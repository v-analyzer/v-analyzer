module psi

pub struct StructDeclaration {
	PsiElementImpl
}

pub fn (s StructDeclaration) identifier() ?PsiElement {
	return s.find_child_by_type(.type_identifier) or {
		s.find_child_by_type(.builtin_type) or {
			s.find_child_by_type(.binded_type) or { return none }
		}
	}
}

pub fn (s StructDeclaration) name() string {
	identifier := s.identifier() or {
		println('StructDeclaration.name: no identifier')
		return ''
	}
	return identifier.get_text()
}
