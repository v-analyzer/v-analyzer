module types

pub const string_type = StringType{}

[noinit]
pub struct StringType {}

pub fn (s &StringType) name() string {
	return 'string'
}

pub fn (s &StringType) qualified_name() string {
	return 'builtin.string'
}

pub fn (s &StringType) readable_name() string {
	return 'string'
}
