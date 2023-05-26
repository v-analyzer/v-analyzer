module types

pub struct OptionType {
	inner    Type
	no_inner bool
}

pub fn new_option_type(inner Type, no_inner bool) &OptionType {
	return &OptionType{
		inner: inner
		no_inner: no_inner
	}
}

pub fn (s &OptionType) name() string {
	if s.no_inner {
		return '?'
	}
	return '?${s.inner.name()}'
}

pub fn (s &OptionType) qualified_name() string {
	if s.no_inner {
		return '?'
	}
	return '?${s.inner.qualified_name()}'
}

pub fn (s &OptionType) readable_name() string {
	if s.no_inner {
		return '?'
	}
	return '?${s.inner.readable_name()}'
}
