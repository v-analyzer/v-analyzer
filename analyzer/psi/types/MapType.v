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

pub struct MapType {
	BaseType
pub:
	key   Type
	value Type
}

pub fn new_map_type(module_name string, key Type, value Type) &MapType {
	return &MapType{
		key: key
		value: value
		module_name: module_name
	}
}

pub fn (s &MapType) name() string {
	return 'map[${s.key.name()}]${s.value.name()}'
}

pub fn (s &MapType) qualified_name() string {
	return 'map[${s.key.name()}]${s.value.qualified_name()}'
}

pub fn (s &MapType) readable_name() string {
	return 'map[${s.key.name()}]${s.value.readable_name()}'
}

pub fn (s &MapType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.key.accept(mut visitor)
	s.value.accept(mut visitor)
}

pub fn (s &MapType) substitute_generics(name_map map[string]Type) Type {
	return new_map_type(s.module_name, s.key.substitute_generics(name_map), s.value.substitute_generics(name_map))
}
