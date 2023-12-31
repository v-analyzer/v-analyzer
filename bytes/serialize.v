// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module bytes

pub struct Serializer {
pub mut:
	data []u8
}

pub fn (mut s Serializer) write_string(str string) {
	s.write_int(str.len)
	for sym in str {
		s.write_u8(sym)
	}
}

pub fn (mut s Serializer) write_int(data int) {
	if data > 0 && data < 0xFF {
		s.write_u8(1)
		s.write_u8(u8(data))
		return
	}

	s.write_u8(0)
	for i in 0 .. 4 {
		s.write_u8(u8(data >> (8 * (3 - i))) & 0xFF)
	}
}

pub fn (mut s Serializer) write_i64(data i64) {
	for i in 0 .. 8 {
		s.write_u8(u8(data >> (8 * (7 - i))) & 0xFF)
	}
}

@[inline]
pub fn (mut s Serializer) write_u8(data u8) {
	s.data << data
}
