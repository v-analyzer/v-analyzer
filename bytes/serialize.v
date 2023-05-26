module bytes

enum BeginSymbols as u8 {
	unknown = 0
	string = 250
	int
	i64
}

pub struct Serializer {
pub mut:
	data []u8
}

pub fn (mut s Serializer) write_string(str string) {
	s.write_u8(u8(BeginSymbols.string))
	s.write_int(str.len)
	for sym in str {
		s.write_u8(sym)
	}
}

pub fn (mut s Serializer) write_int(data int) {
	s.write_u8(u8(BeginSymbols.int))
	for i in 0 .. 4 {
		s.write_u8(u8(data >> (8 * (3 - i))) & 0xFF)
	}
}

pub fn (mut s Serializer) write_i64(data i64) {
	s.write_u8(u8(BeginSymbols.i64))
	for i in 0 .. 8 {
		s.write_u8(u8(data >> (8 * (7 - i))) & 0xFF)
	}
}

[inline]
pub fn (mut s Serializer) write_u8(data u8) {
	s.data << data
}
