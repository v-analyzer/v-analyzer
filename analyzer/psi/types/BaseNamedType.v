module types

struct BaseNamedType {
	module_name string
	name        string
}

pub fn (s &BaseNamedType) name() string {
	return s.name
}

pub fn (s &BaseNamedType) qualified_name() string {
	if s.module_name == '' {
		return s.name
	}
	return s.module_name + '.' + s.name
}

pub fn (s &BaseNamedType) readable_name() string {
	if s.module_name == '' {
		return s.name
	}
	last_module := s.module_name.split('.').last()
	return last_module + '.' + s.name
}
