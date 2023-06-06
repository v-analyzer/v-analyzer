module types

pub struct ChannelType {
	inner Type
}

pub fn new_channel_type(inner Type) &ChannelType {
	return &ChannelType{
		inner: inner
	}
}

pub fn (s &ChannelType) name() string {
	return 'chan ${s.inner.name()}'
}

pub fn (s &ChannelType) qualified_name() string {
	return 'chan ${s.inner.qualified_name()}'
}

pub fn (s &ChannelType) readable_name() string {
	return 'chan ${s.inner.readable_name()}'
}

pub fn (s &ChannelType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}
