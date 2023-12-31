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
module semantic

import lsp
import utils
import analyzer.psi

pub struct ResolveSemanticVisitor {
	start      u32  // start offset when request range is specified
	end        u32  // end offset when request range is specified
	with_range bool // whether request range is specified
}

pub fn new_resolve_semantic_visitor(range lsp.Range, containing_file &psi.PsiFile) ResolveSemanticVisitor {
	start := utils.compute_offset(containing_file.source_text, range.start.line, range.start.character)
	end := utils.compute_offset(containing_file.source_text, range.end.line, range.end.character)

	return ResolveSemanticVisitor{
		with_range: !range.is_empty()
		start: u32(start)
		end: u32(end)
	}
}

pub fn (v ResolveSemanticVisitor) accept(root psi.PsiElement) []SemanticToken {
	mut result := []SemanticToken{cap: 400}

	for node in psi.new_psi_tree_walker(root) {
		range := node.node.range()
		if v.with_range && (range.end_byte <= v.start || range.start_byte >= v.end) {
			continue
		}

		v.highlight_node(node, root, mut result)
	}

	return result
}

@[inline]
fn (_ ResolveSemanticVisitor) highlight_node(node psi.PsiElement, root psi.PsiElement, mut result []SemanticToken) {
	if node is psi.VarDefinition {
		if node.is_mutable() {
			if identifier := node.identifier() {
				result << element_to_semantic(identifier.node, .variable, 'mutable')
			}
		}
	}

	res, first_child := if node is psi.ReferenceExpression || node is psi.TypeReferenceExpression {
		res := (node as psi.ReferenceExpressionBase).resolve() or { return }
		first_child := (node as psi.PsiElement).node.first_child() or { return }
		res, first_child
	} else {
		return
	}

	if res is psi.VarDefinition {
		mut mods := []string{}
		if res.is_mutable() {
			mods << 'mutable'
		}
		result << element_to_semantic(first_child, .variable, ...mods)
	} else if res is psi.ConstantDefinition {
		result << element_to_semantic(first_child, .property)
	} else if res is psi.InterfaceDeclaration {
		result << element_to_semantic(first_child, .interface_)
	} else if res is psi.StructDeclaration {
		if res.name() != 'string' && res.module_name() != 'stubs.attributes' {
			result << element_to_semantic(first_child, .struct_)
		}
	} else if res is psi.EnumDeclaration {
		result << element_to_semantic(first_child, .enum_)
	} else if res is psi.FieldDeclaration {
		result << element_to_semantic(first_child, .property)
	} else if res is psi.EnumFieldDeclaration {
		result << element_to_semantic(first_child, .enum_member)
	} else if res is psi.ParameterDeclaration {
		mut mods := []string{}
		if res.is_mutable() {
			mods << 'mutable'
		}
		result << element_to_semantic(first_child, .parameter, ...mods)
	} else if res is psi.Receiver {
		mut mods := []string{}
		if res.is_mutable() {
			mods << 'mutable'
		}
		result << element_to_semantic(first_child, .parameter, ...mods)
	} else if res is psi.ImportSpec {
		result << element_to_semantic(first_child, .namespace)
	} else if res is psi.ModuleClause {
		result << element_to_semantic(first_child, .namespace)
	} else if res is psi.TypeAliasDeclaration {
		from_stubs := res.containing_file.path.contains('stubs')
		if !from_stubs {
			result << element_to_semantic(first_child, .type_)
		}
	} else if res is psi.GenericParameter {
		result << element_to_semantic(first_child, .type_parameter)
	} else if res is psi.FunctionOrMethodDeclaration {
		result << element_to_semantic(first_child, .function)
	} else if res is psi.GlobalVarDefinition {
		result << element_to_semantic(first_child, .variable, 'global')
	} else if res is psi.EmbeddedDefinition {
		result << element_to_semantic(first_child, .struct_)
	}
}
