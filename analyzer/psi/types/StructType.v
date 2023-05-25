module types

pub const string_type = new_struct_type('string')

pub struct StructType {
	name string
}

pub fn new_struct_type(name string) &StructType {
	return &StructType{
		name: name
	}
}

pub fn (s &StructType) name() string {
	return s.name
}

pub fn (s &StructType) qualified_name() string {
	return s.name
}

pub fn (s &StructType) readable_name() string {
	return s.name
}
