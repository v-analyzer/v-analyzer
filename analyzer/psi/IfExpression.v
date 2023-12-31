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

pub struct IfExpression {
	PsiElementImpl
}

pub fn (n IfExpression) var_definition() ?&VarDefinition {
	decl := n.find_child_by_type(.var_declaration)?
	list := decl.first_child()?
	expr := list.first_child()?
	if expr is VarDefinition {
		return expr
	}
	if expr is MutExpression {
		var := expr.last_child()?
		if var is VarDefinition {
			return var
		}
	}
	return none
}

pub fn (n IfExpression) block() ?&Block {
	block := n.find_child_by_type(.block)?
	if block is Block {
		return block
	}
	return none
}

pub fn (n IfExpression) else_branch() ?PsiElement {
	else_branch := n.find_child_by_type(.else_branch)?
	return else_branch.last_child()
}
