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

pub struct Deserializer {
mut:
	index int
	data  []u8
}

pub fn new_deserializer(data []u8) Deserializer {
	return Deserializer{
		data: data
	}
}

pub fn (mut s Deserializer) read_string() string {
	len := s.read_int()
	if len == 0 {
		return ''
	}

	data := s.data[s.index..s.index + len]
	s.index += len
	return data.bytestr()
}

pub fn (mut s Deserializer) read_int() int {
	first := s.read_u8()
	if first == 1 {
		return s.read_u8()
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
	data := s.data[s.index..s.index + 8]
	s.index += 8
	mut res := 0
	for index, datum in data {
		res |= datum << (8 * (7 - index))
	}
	return res
}

@[inline]
pub fn (mut s Deserializer) read_u8() u8 {
	index := s.index
	s.index++
	return s.data[index]
}
