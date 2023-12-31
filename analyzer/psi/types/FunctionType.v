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

import strings

pub struct FunctionType {
	BaseType
pub:
	params    []Type
	result    Type
	no_result bool
}

pub fn new_function_type(module_name string, params []Type, result Type, no_result bool) &FunctionType {
	return &FunctionType{
		params: params
		result: result
		no_result: no_result
		module_name: module_name
	}
}

pub fn (s &FunctionType) name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.name())
		if index < s.params.len - 1 {
			sb.write_string(', ')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.name())
	}

	return sb.str()
}

pub fn (s &FunctionType) qualified_name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.qualified_name())
		if index < s.params.len - 1 {
			sb.write_string(', ')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.qualified_name())
	}

	return sb.str()
}

pub fn (s &FunctionType) readable_name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.readable_name())
		if index < s.params.len - 1 {
			sb.write_string(', ')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.readable_name())
	}

	return sb.str()
}

pub fn (s &FunctionType) accept(mut visitor TypeVisitor) {
	if !visitor.enter(s) {
		return
	}

	for param in s.params {
		param.accept(mut visitor)
	}

	s.result.accept(mut visitor)
}

pub fn (s &FunctionType) substitute_generics(name_map map[string]Type) Type {
	params := s.params.map(it.substitute_generics(name_map))
	result := s.result.substitute_generics(name_map)
	return new_function_type(s.module_name, params, result, s.no_result)
}
