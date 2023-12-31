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
module semantic

import analyzer.psi

@[json_as_number]
enum SemanticTypes as u32 {
	namespace
	type_
	class
	enum_
	interface_
	struct_
	type_parameter
	parameter
	variable
	property
	enum_member
	event
	function
	method
	macro
	keyword
	modifier
	comment
	string
	number
	regexp
	operator
	decorator
}

pub struct SemanticToken {
	line  u32
	start u32
	len   u32
	typ   SemanticTypes
	mods  []string
}

@[inline]
fn element_to_semantic(element psi.AstNode, typ SemanticTypes, modifiers ...string) SemanticToken {
	start_point := element.start_point()
	return SemanticToken{
		line: start_point.row
		start: start_point.column
		len: element.text_length()
		typ: typ
		mods: modifiers
	}
}
