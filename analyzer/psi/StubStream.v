module psi

pub struct StubOutputStream {
mut:
	data []u8
}

pub fn new_stub_output_stream(data []u8) &StubOutputStream {
	return &StubOutputStream{
		data: data
	}
}

pub fn (mut s StubOutputStream) write_u8(ch u8) {
	s.data << ch
}

pub fn (mut s StubOutputStream) write_name(name string) {
	s.data << name.bytes()
}

pub struct StubInputStream {
	data []u8
}

pub fn new_stub_input_stream(data []u8) &StubOutputStream {
	return &StubOutputStream{
		data: data
	}
}

pub fn (s &StubInputStream) read_u8() u8 {
	return 0
}

pub fn (s &StubInputStream) read_name() string {
	return '' // TODO
}
