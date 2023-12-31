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

pub struct VarDefinition {
	PsiElementImpl
}

pub fn (_ &VarDefinition) is_public() bool {
	return true
}

pub fn (n &VarDefinition) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &VarDefinition) identifier_text_range() TextRange {
	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n &VarDefinition) name() string {
	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (n &VarDefinition) declaration() ?&VarDeclaration {
	if parent := n.parent_nth(2) {
		if parent is VarDeclaration {
			return parent
		}
	}
	if parent := n.parent_nth(3) {
		if parent is VarDeclaration {
			return parent
		}
	}
	return none
}

pub fn (n &VarDefinition) get_type() types.Type {
	return infer_type(n)
}

pub fn (n &VarDefinition) mutability_modifiers() ?&MutabilityModifiers {
	if mut_expr := n.parent() {
		if mut_expr.node.type_name == .mutable_expression {
			modifiers := mut_expr.find_child_by_type(.mutability_modifiers)?
			if modifiers is MutabilityModifiers {
				return modifiers
			}
		}
	}

	return none
}

pub fn (n &VarDefinition) is_mutable() bool {
	mods := n.mutability_modifiers() or {
		if first_child := n.first_child() {
			if first_child.text_matches('mut') {
				return true
			}
		}

		if grand := n.parent_nth(4) {
			if grand.element_type() == .for_clause {
				// variable inside for loop initializer is mutable by default
				return true
			}
		}
		return false
	}
	return mods.is_mutable()
}
