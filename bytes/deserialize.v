module bytes

pub struct Deserializer {
mut:
	index int
	data  []u8
}

pub fn new_deserializer(data []u8) &Deserializer {
	return &Deserializer{
		data: data
	}
}

pub fn (mut s Deserializer) read_string() string {
	begin := s.read_begin_symbol()
	if begin != .string {
		// TODO: сделать другую обработку ошибок, возможно записывать в массив и потом отдавать
		panic('Expected string at ${s.index}, got ${begin}')
	}
	len := s.read_int()
	data := s.data[s.index..s.index + len]
	s.index += len
	return data.bytestr()
}

pub fn (mut s Deserializer) read_int() int {
	begin := s.read_begin_symbol()
	if begin != .int {
		panic('Expected int at ${s.index}, got ${begin}')
	}
	data := s.data[s.index..s.index + 4]
	s.index += 4
	mut res := 0
	for index, datum in data {
		res |= datum << (8 * (3 - index))
	}
	return res
}

pub fn (mut s Deserializer) read_i64() i64 {
	begin := s.read_begin_symbol()
	if begin != .i64 {
		panic('Expected i64 at ${s.index}, got ${begin}')
	}
	data := s.data[s.index..s.index + 8]
	s.index += 8
	mut res := 0
	for index, datum in data {
		res |= datum << (8 * (7 - index))
	}
	return res
}

[inline]
pub fn (mut s Deserializer) read_u8() u8 {
	index := s.index
	s.index++
	return s.data[index]
}

[inline]
pub fn (mut s Deserializer) read_begin_symbol() BeginSymbols {
	data := s.read_u8()
	if data < 250 {
		return .unknown
	}

	return unsafe { BeginSymbols(data) }
}
