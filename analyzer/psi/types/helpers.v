module types

pub fn unwrap_pointer_type(typ Type) Type {
	if typ is PointerType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_alias_type(typ Type) Type {
	if typ is AliasType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_channel_type(typ Type) Type {
	if typ is ChannelType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_result_or_option_type(typ Type) Type {
	if typ is ResultType {
		return typ.inner
	}
	if typ is OptionType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_result_or_option_type_if(typ Type, condition bool) Type {
	if condition {
		return unwrap_result_or_option_type(typ)
	}
	return typ
}
