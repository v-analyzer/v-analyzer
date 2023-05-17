module types

pub struct EnumType {
	name string
}

pub fn new_enum_type(name string) &EnumType {
	return &EnumType{
		name: name
	}
}

pub fn (s &EnumType) name() string {
	return s.name
}

pub fn (s &EnumType) qualified_name() string {
	return s.name
}

pub fn (s &EnumType) readable_name() string {
	return s.name
}
