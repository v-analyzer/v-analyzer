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

pub struct ParameterDeclaration {
	PsiElementImpl
}

fn (p &ParameterDeclaration) stub() {}

pub fn (_ &ParameterDeclaration) is_public() bool {
	return true
}

pub fn (p &ParameterDeclaration) get_type() types.Type {
	return infer_type(p)
}

pub fn (p &ParameterDeclaration) identifier() ?PsiElement {
	return p.find_child_by_type(.identifier)
}

pub fn (p &ParameterDeclaration) identifier_text_range() TextRange {
	if stub := p.get_stub() {
		return stub.identifier_text_range
	}

	identifier := p.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (p &ParameterDeclaration) name() string {
	if stub := p.get_stub() {
		return stub.name
	}

	identifier := p.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (p &ParameterDeclaration) mutability_modifiers() ?&MutabilityModifiers {
	modifiers := p.find_child_by_type_or_stub(.mutability_modifiers)?
	if modifiers is MutabilityModifiers {
		return modifiers
	}
	return none
}

pub fn (p &ParameterDeclaration) is_mutable() bool {
	mods := p.mutability_modifiers() or { return false }
	return mods.is_mutable()
}
