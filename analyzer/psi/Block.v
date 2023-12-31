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

pub struct Block {
	PsiElementImpl
}

pub fn (b Block) last_expression() ?PsiElement {
	statements := b.find_children_by_type(.simple_statement)
	if statements.len == 0 {
		return none
	}
	return statements.last().first_child()
}

pub fn (b Block) process_declarations(mut processor PsiScopeProcessor, last_parent PsiElement) bool {
	statements := b.find_children_by_type(.simple_statement)
	for statement in statements {
		if statement.is_equal(last_parent) {
			return true
		}

		first_child := statement.first_child() or { continue }

		if first_child is VarDeclaration {
			for var in first_child.vars() {
				if !processor.execute(var) {
					return false
				}
			}
		}
	}
	return true
}
