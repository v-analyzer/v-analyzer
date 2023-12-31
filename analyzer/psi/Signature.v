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

import analyzer.psi.types

pub struct Signature {
	PsiElementImpl
}

pub fn (s &Signature) get_type() types.Type {
	return infer_type(s)
}

pub fn (n Signature) parameters() []PsiElement {
	mut parameters := []PsiElement{}
	list := n.find_child_by_type_or_stub(.parameter_list) or { return parameters }
	parameters << list.find_children_by_type_or_stub(.parameter_declaration)
	list_type := n.find_child_by_type_or_stub(.type_parameter_list) or { return parameters }
	parameters << list_type.find_children_by_type_or_stub(.type_parameter_declaration)
	return parameters
}

pub fn (n Signature) result() ?PsiElement {
	last := n.last_child_or_stub()?
	if last is PlainType {
		return last
	}
	return none
}

fn (_ &Signature) stub() {}
