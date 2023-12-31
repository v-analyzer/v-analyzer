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

pub fn get_it_call(element PsiElement) ?&CallExpression {
	mut parent_call := element.parent_of_type(.call_expression)?
	if mut parent_call is CallExpression {
		for {
			expression := parent_call.expression() or { break }
			if expression.is_parent_of(element) {
				// when it used as expression of call
				// it.foo()
				parent_call = parent_call.parent_of_type(.call_expression) or { break }
				continue
			}

			break
		}
	}

	methods_names := ['filter', 'map', 'any', 'all']
	if mut parent_call is CallExpression {
		for !is_array_method_call(*parent_call, ...methods_names) {
			parent_call = parent_call.parent_of_type(.call_expression) or { break }
		}
	}

	if mut parent_call is CallExpression {
		return parent_call
	}

	return none
}

pub fn is_array_method_call(element CallExpression, names ...string) bool {
	ref_expression := element.ref_expression() or { return false }
	last_child := (ref_expression as PsiElement).last_child() or { return false }
	called_name := last_child.get_text()
	return called_name in names
}
