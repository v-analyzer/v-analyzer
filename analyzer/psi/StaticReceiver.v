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

pub struct StaticReceiver {
	PsiElementImpl
}

pub fn (_ &StaticReceiver) is_public() bool {
	return true
}

fn (r &StaticReceiver) identifier_text_range() TextRange {
	if stub := r.get_stub() {
		return stub.identifier_text_range
	}

	identifier := r.identifier() or { return TextRange{} }
	return identifier.text_range()
}

fn (r &StaticReceiver) identifier() ?PsiElement {
	return r.find_child_by_type(.identifier)
}

pub fn (r &StaticReceiver) name() string {
	if stub := r.get_stub() {
		return stub.name
	}

	identifier := r.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (r &StaticReceiver) get_type() types.Type {
	return infer_type(r.first_child())
}

fn (_ &StaticReceiver) stub() {}
