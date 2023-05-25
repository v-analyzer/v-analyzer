module types

pub struct MapType {
pub:
	key   Type
	value Type
}

pub fn new_map_type(key Type, value Type) &MapType {
	return &MapType{
		key: key
		value: value
	}
}

pub fn (s &MapType) name() string {
	return 'map[${s.key.name()}]${s.value.name()}'
}

pub fn (s &MapType) qualified_name() string {
	return 'map[${s.key.name()}]${s.value.qualified_name()}'
}

pub fn (s &MapType) readable_name() string {
	return 'map[${s.key.name()}]${s.value.readable_name()}'
}
