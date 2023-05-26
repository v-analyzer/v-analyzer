module types

pub fn unwrap_pointer_type(typ Type) Type {
	if typ is PointerType {
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

pub fn unwrap_result_pr_option_type(typ Type) Type {
	if typ is ResultType {
		return typ.inner
	}
	if typ is OptionType {
		return typ.inner
	}
	return typ
}
