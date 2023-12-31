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

// inspect traverses an AST in depth-first order: It starts by calling
// `cb(node)`; node must not be `nil`. If call returns `true`, `inspect` invokes `cb`
// recursively for each of the non-nil children of node. Otherwise, `inspect` skips
// the children of node.
//
// Example:
// ```
// inspect(root, fn (node PsiElement) bool {
//   match node {
//     psi.FunctionDeclaration {
//       println('function ${node.name()}')
//     }
//     else {}
//   }
//   return true
// })
pub fn inspect(node PsiElement, cb fn (PsiElement) bool) {
	inspector := Inspector{
		cb: cb
	}
	node.accept(inspector)
}

struct Inspector {
	cb fn (PsiElement) bool = unsafe { nil }
}

fn (r &Inspector) visit_element(element PsiElement) {
	if !r.visit_element_impl(element) {
		return
	}
	mut child := element.first_child() or { return }
	for {
		child.accept(r)
		child = child.next_sibling() or { break }
	}
}

fn (i &Inspector) visit_element_impl(element PsiElement) bool {
	return i.cb(create_element(element.node, element.containing_file))
}
