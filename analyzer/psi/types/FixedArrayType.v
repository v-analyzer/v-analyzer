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

pub struct FixedArrayType {
pub:
	inner Type
	size  int
}

pub fn new_fixed_array_type(inner Type, size int) &FixedArrayType {
	return &FixedArrayType{
		inner: inner
		size: size
	}
}

pub fn (s &FixedArrayType) name() string {
	return '[${s.size}]${s.inner.name()}'
}

pub fn (s &FixedArrayType) qualified_name() string {
	return '[${s.size}]${s.inner.qualified_name()}'
}

pub fn (s &FixedArrayType) readable_name() string {
	return '[${s.size}]${s.inner.readable_name()}'
}

pub fn (s &FixedArrayType) module_name() string {
	return s.inner.module_name()
}

pub fn (s &FixedArrayType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}

pub fn (s &FixedArrayType) substitute_generics(name_map map[string]Type) Type {
	return new_fixed_array_type(s.inner.substitute_generics(name_map), s.size)
}
