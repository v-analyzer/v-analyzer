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

pub struct Receiver {
	PsiElementImpl
}

pub fn (r &Receiver) is_public() bool {
	return true
}

fn (r &Receiver) identifier_text_range() TextRange {
	if stub := r.get_stub() {
		return stub.identifier_text_range
	}

	identifier := r.identifier() or { return TextRange{} }
	return identifier.text_range()
}

fn (r &Receiver) identifier() ?PsiElement {
	return r.find_child_by_type(.identifier)
}

pub fn (r &Receiver) name() string {
	if stub := r.get_stub() {
		return stub.name
	}

	identifier := r.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (r &Receiver) type_element() ?PsiElement {
	if stub := r.get_stub() {
		if receiver_stub := stub.get_child_by_type(.plain_type) {
			psi := receiver_stub.get_psi()?
			if psi is PlainType {
				return psi
			}
		}
		return none
	}

	return r.find_child_by_type(.plain_type)
}

pub fn (r &Receiver) get_type() types.Type {
	return infer_type(r)
}

pub fn (r &Receiver) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := r.find_child_by_type_or_stub(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}

pub fn (r &Receiver) is_mutable() bool {
	mods := r.mutability_modifiers() or { return false }
	return mods.is_mutable()
}

fn (_ &Receiver) stub() {}
