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

pub struct ForStatement {
	PsiElementImpl
}

pub fn (n ForStatement) var_definitions() []PsiElement {
	if range_clause := n.find_child_by_type(.range_clause) {
		var_definition_list := range_clause.find_child_by_type(.var_definition_list) or {
			return []
		}
		return var_definition_list.find_children_by_type(.var_definition)
	}

	if for_clause := n.find_child_by_type(.for_clause) {
		initializer := for_clause.first_child() or { return [] }
		if initializer.element_type() == .simple_statement {
			decl := initializer.first_child() or { return [] }
			list := decl.first_child() or { return [] }
			definition := list.first_child() or { return [] }
			return [definition]
		}
	}

	return []
}
