module types

pub struct GenericType {
	BaseNamedType
}

pub fn new_generic_type(name string, module_name string) &GenericType {
	return &GenericType{
		name: name
		module_name: module_name
	}
}

pub fn (s &GenericType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}
}
