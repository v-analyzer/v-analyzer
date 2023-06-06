module types

pub const string_type = new_struct_type('string', 'builtin')

pub const builtin_array_type = new_struct_type('array', 'builtin')

pub const builtin_map_type = new_struct_type('map', 'builtin')

pub struct StructType {
	BaseNamedType
}

pub fn new_struct_type(name string, module_name string) &StructType {
	return &StructType{
		name: name
		module_name: module_name
	}
}

pub fn (s &StructType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}
}
