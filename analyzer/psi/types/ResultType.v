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

pub struct ResultType {
pub:
	inner    Type
	no_inner bool
}

pub fn new_result_type(inner Type, no_inner bool) &ResultType {
	return &ResultType{
		inner: inner
		no_inner: no_inner
	}
}

pub fn (s &ResultType) name() string {
	if s.no_inner {
		return '!'
	}
	return '!${s.inner.name()}'
}

pub fn (s &ResultType) qualified_name() string {
	if s.no_inner {
		return '!'
	}
	return '!${s.inner.qualified_name()}'
}

pub fn (s &ResultType) readable_name() string {
	if s.no_inner {
		return '!'
	}
	return '!${s.inner.readable_name()}'
}

pub fn (s &ResultType) module_name() string {
	return s.inner.module_name()
}

pub fn (s &ResultType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)
}

pub fn (s &ResultType) substitute_generics(name_map map[string]Type) Type {
	return new_result_type(s.inner.substitute_generics(name_map), s.no_inner)
}
