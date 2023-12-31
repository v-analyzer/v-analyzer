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
module types

pub struct PrimitiveType {
pub:
	name string
}

pub fn new_primitive_type(name string) &PrimitiveType {
	return &PrimitiveType{
		name: name
	}
}

fn (s &PrimitiveType) name() string {
	return s.name
}

fn (s &PrimitiveType) qualified_name() string {
	return s.name
}

fn (s &PrimitiveType) readable_name() string {
	return s.name
}

pub fn (s &PrimitiveType) module_name() string {
	return 'builtin'
}

pub fn is_primitive_type(typ string) bool {
	return typ in ['i8', 'i16', 'i32', 'int', 'i64', 'byte', 'u8', 'u16', 'u32', 'u64', 'f32',
		'f64', 'char', 'bool', 'rune', 'usize', 'isize']
}

pub fn (s &PrimitiveType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}
}

pub fn (s &PrimitiveType) substitute_generics(name_map map[string]Type) Type {
	return s
}
