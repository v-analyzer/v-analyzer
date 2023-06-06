module types

pub struct PointerType {
pub:
	inner Type
}

pub fn new_pointer_type(inner Type) &PointerType {
	return &PointerType{
		inner: inner
	}
}

pub fn (s &PointerType) name() string {
	return '&${s.inner.name()}'
}

pub fn (s &PointerType) qualified_name() string {
	return '&${s.inner.qualified_name()}'
}

pub fn (s &PointerType) readable_name() string {
	return '&${s.inner.readable_name()}'
}

pub fn (s &PointerType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}
