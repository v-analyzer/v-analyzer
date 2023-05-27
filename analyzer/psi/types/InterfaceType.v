module types

pub struct InterfaceType {
	BaseNamedType
}

pub fn new_interface_type(name string, module_name string) &InterfaceType {
	return &InterfaceType{
		name: name
		module_name: module_name
	}
}
