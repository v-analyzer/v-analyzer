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

pub struct GenericInstantiationType {
pub:
	inner          Type
	specialization []Type
}

pub fn new_generic_instantiation_type(inner Type, specialization []Type) &GenericInstantiationType {
	return &GenericInstantiationType{
		inner: inner
		specialization: specialization
	}
}

pub fn (s &GenericInstantiationType) name() string {
	return '${s.inner.name()}[${s.specialization.map(it.name()).join(', ')}]'
}

pub fn (s &GenericInstantiationType) qualified_name() string {
	return '${s.inner.qualified_name()}[${s.specialization.map(it.qualified_name()).join(', ')}]'
}

pub fn (s &GenericInstantiationType) readable_name() string {
	return '${s.inner.readable_name()}[${s.specialization.map(it.readable_name()).join(', ')}]'
}

pub fn (s &GenericInstantiationType) module_name() string {
	return s.inner.module_name()
}

pub fn (s &GenericInstantiationType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	s.inner.accept(mut visitor)

	for specialization in s.specialization {
		specialization.accept(mut visitor)
	}
}

pub fn (s &GenericInstantiationType) substitute_generics(name_map map[string]Type) Type {
	inner := s.inner.substitute_generics(name_map)
	specialization := s.specialization.map(it.substitute_generics(name_map))
	return new_generic_instantiation_type(inner, specialization)
}
