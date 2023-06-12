module types

pub struct MapType {
	BaseType
pub:
	key   Type
	value Type
}

pub fn new_map_type(module_name string, key Type, value Type) &MapType {
	return &MapType{
		key: key
		value: value
		module_name: module_name
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

pub fn (s &MapType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.key.accept(mut visitor)
	s.value.accept(mut visitor)
}
