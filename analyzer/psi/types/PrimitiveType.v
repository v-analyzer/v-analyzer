module types

pub struct PrimitiveType {
	name string
}

pub fn new_primitive_type(name string) &PrimitiveType {
	return &PrimitiveType{
		name: name
	}
}

fn (s &PrimitiveType) name() string {
	return s.name
}

fn (s &PrimitiveType) qualified_name() string {
	return s.name
}

fn (s &PrimitiveType) readable_name() string {
	return s.name
}
