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
module intentions

import analyzer.psi

fn find_declaration_at_pos(file &psi.PsiFile, pos psi.Position) ?psi.PsiNamedElement {
	element := file.find_element_at_pos(pos) or { return none }
	if element !is psi.Identifier {
		return none
	}

	parent := element.parent() or { return none }
	if parent is psi.PsiNamedElement {
		return parent
	}

	if parent.node.type_name == .overridable_operator {
		grand := parent.parent() or { return none }
		if grand is psi.PsiNamedElement {
			return grand
		}
	}

	return none
}

fn find_reference_at_pos(file &psi.PsiFile, pos psi.Position) ?&psi.ReferenceExpression {
	element := file.find_element_at_pos(pos) or { return none }
	parent := element.parent() or { return none }
	if parent is psi.ReferenceExpression {
		return parent
	}

	return none
}
