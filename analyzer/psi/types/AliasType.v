module types

pub struct AliasType {
	BaseNamedType
pub:
	inner Type
}

pub fn new_alias_type(name string, module_name string, inner Type) &AliasType {
	return &AliasType{
		name: name
		module_name: module_name
		inner: inner
	}
}

pub fn (s &AliasType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}
