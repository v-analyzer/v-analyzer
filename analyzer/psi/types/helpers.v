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
