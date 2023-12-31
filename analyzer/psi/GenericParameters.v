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
module psi

import strings

pub struct GenericParameters {
	PsiElementImpl
}

fn (_ &GenericParameters) stub() {}

pub fn (n &GenericParameters) parameters() []GenericParameter {
	params := n.find_children_by_type_or_stub(.generic_parameter)
	mut result := []GenericParameter{cap: params.len}
	for param in params {
		if param is GenericParameter {
			result << param
		}
	}
	return result
}

pub fn (n &GenericParameters) text_presentation() string {
	parameters := n.parameters()
	if parameters.len == 0 {
		return ''
	}
	mut sb := strings.new_builder(5)
	sb.write_string('[')
	for index, parameter in parameters {
		sb.write_string(parameter.name())
		if index < parameters.len - 1 {
			sb.write_string(', ')
		}
	}
	sb.write_string(']')
	return sb.str()
}

pub fn (n &GenericParameters) parameter_names() []string {
	parameters := n.parameters()
	if parameters.len == 0 {
		return []
	}

	mut result := []string{cap: parameters.len}
	for parameter in parameters {
		result << parameter.name()
	}
	return result
}
