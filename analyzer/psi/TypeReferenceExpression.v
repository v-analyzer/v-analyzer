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

pub struct TypeReferenceExpression {
	PsiElementImpl
}

fn (_ &TypeReferenceExpression) stub() {}

pub fn (_ TypeReferenceExpression) is_public() bool {
	return true
}

pub fn (r TypeReferenceExpression) identifier() ?PsiElement {
	return r.first_child()
}

pub fn (r &TypeReferenceExpression) identifier_text_range() TextRange {
	if stub := r.get_stub() {
		return stub.identifier_text_range
	}

	identifier := r.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (r TypeReferenceExpression) name() string {
	if stub := r.get_stub() {
		return stub.text
	}

	identifier := r.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (r TypeReferenceExpression) qualifier() ?PsiElement {
	parent := r.parent()?

	if parent is QualifiedType {
		left := parent.left()?
		if left.is_equal(r) {
			return none
		}

		return left
	}

	return none
}

pub fn (r TypeReferenceExpression) reference() PsiReference {
	return new_reference(r.containing_file, r, true)
}

pub fn (r TypeReferenceExpression) resolve() ?PsiElement {
	return r.reference().resolve()
}

pub fn (r TypeReferenceExpression) get_type() types.Type {
	element := r.resolve() or { return types.unknown_type }

	if element is PsiTypedElement {
		return element.get_type()
	}

	return types.unknown_type
}
