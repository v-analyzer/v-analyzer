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

pub const string_type = new_struct_type('string', 'builtin')

pub const builtin_array_type = new_struct_type('array', 'builtin')

pub const builtin_map_type = new_struct_type('map', 'builtin')

pub const array_init_type = new_struct_type('ArrayInit', 'stubs')

pub const chan_init_type = new_struct_type('ChanInit', 'stubs')

pub const flag_enum_type = new_enum_type('FlagEnum', 'stubs')

pub const any_type = new_alias_type('Any', 'stubs', unknown_type)

pub struct StructType {
	BaseNamedType
}

pub fn new_struct_type(name string, module_name string) &StructType {
	return &StructType{
		name: name
		module_name: module_name
	}
}

pub fn (s &StructType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}
}

pub fn (s &StructType) substitute_generics(name_map map[string]Type) Type {
	return s
}
