module semantic

import analyzer.psi

pub struct ResolveSemanticVisitor {}

pub fn (v ResolveSemanticVisitor) accept(root psi.PsiElement) []SemanticToken {
	mut result := []SemanticToken{cap: 400}

	for node in psi.new_psi_tree_walker(root) {
		v.highlight_node(node, root, mut result)
	}

	return result
}

[inline]
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
	} else if res is psi.StructDeclaration {
		if res.name() != 'string' {
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
			result << element_to_semantic(first_child, .namespace)
		}
	} else if res is psi.GenericParameter {
		result << element_to_semantic(first_child, .type_parameter)
	} else if res is psi.FunctionOrMethodDeclaration {
		result << element_to_semantic(first_child, .function)
	} else if res is psi.GlobalVarDefinition {
		result << element_to_semantic(first_child, .variable, 'global')
	}
}
