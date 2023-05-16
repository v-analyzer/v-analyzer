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

pub fn is_primitive_type(typ string) bool {
	return typ in ['i8', 'i16', 'i32', 'int', 'i64', 'byte', 'u8', 'u16', 'u32', 'u64', 'f32',
		'f64', 'char', 'bool', 'rune', 'usize', 'isize']
}
