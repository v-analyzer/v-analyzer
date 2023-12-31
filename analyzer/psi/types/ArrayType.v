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

pub struct ArrayType {
pub:
	inner Type
}

pub fn new_array_type(inner Type) &ArrayType {
	return &ArrayType{
		inner: inner
	}
}

pub fn (s &ArrayType) name() string {
	return '[]${s.inner.name()}'
}

pub fn (s &ArrayType) qualified_name() string {
	return '[]${s.inner.qualified_name()}'
}

pub fn (s &ArrayType) readable_name() string {
	return '[]${s.inner.readable_name()}'
}

pub fn (s &ArrayType) module_name() string {
	return s.inner.module_name()
}

pub fn (s &ArrayType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}

pub fn (s &ArrayType) substitute_generics(name_map map[string]Type) Type {
	return new_array_type(s.inner.substitute_generics(name_map))
}
