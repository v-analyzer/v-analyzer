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

pub struct VarDeclaration {
	PsiElementImpl
}

fn (v VarDeclaration) index_of(def VarDefinition) int {
	first_child := v.first_child() or { return -1 }
	children := first_child.children()
		.filter(it is VarDefinition || it is MutExpression)
		.map(fn (it PsiElement) PsiElement {
			if it is MutExpression {
				return it.last_child() or { return it }
			}
			return it
		})

	for i, definition in children {
		if definition.is_equal(def) {
			return i
		}
	}
	return -1
}

fn (v VarDeclaration) initializer_of(def VarDefinition) ?PsiElement {
	index := v.index_of(def)
	if index == -1 {
		return none
	}

	expressions := v.expressions()
	if expressions.len == 1 && expressions.first() is CallExpression {
		return expressions.first()
	}

	if index >= expressions.len {
		return none
	}

	return expressions[index]
}

pub fn (v VarDeclaration) vars() []PsiElement {
	first_child := v.first_child() or { return [] }
	return first_child
		.children()
		.filter(it is VarDefinition || it is MutExpression)
		.map(fn (it PsiElement) PsiElement {
			if it is MutExpression {
				return it.last_child() or { return it }
			}
			return it
		})
}

fn (v VarDeclaration) expressions() []PsiElement {
	last_child := v.last_child() or { return [] }
	return last_child.children()
}
