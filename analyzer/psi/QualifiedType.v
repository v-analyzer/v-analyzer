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

pub struct QualifiedType {
	PsiElementImpl
}

fn (n &QualifiedType) name() string {
	return ''
}

fn (n &QualifiedType) qualifier() ?PsiElement {
	return n.first_child_or_stub()
}

fn (n &QualifiedType) reference() PsiReference {
	ref_expr := n.right()
	return new_reference(n.containing_file, ref_expr as ReferenceExpressionBase, true)
}

fn (n &QualifiedType) resolve() ?PsiElement {
	return n.reference().resolve()
}

fn (n &QualifiedType) get_type() types.Type {
	right := n.right() or { return types.unknown_type }
	if right is ReferenceExpressionBase {
		resolved := right.resolve() or { return types.unknown_type }
		if resolved is PsiTypedElement {
			return resolved.get_type()
		}
	}

	return types.unknown_type
}

pub fn (n QualifiedType) left() ?PsiElement {
	return n.first_child_or_stub()
}

pub fn (n QualifiedType) right() ?PsiElement {
	return n.last_child_or_stub()
}
