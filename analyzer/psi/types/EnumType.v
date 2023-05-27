module types

pub struct EnumType {
	BaseNamedType
}

pub fn new_enum_type(name string, module_name string) &EnumType {
	return &EnumType{
		name: name
		module_name: module_name
	}
}
