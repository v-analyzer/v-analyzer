module search

import analyzer.psi

pub fn references(element psi.PsiElement) []psi.PsiElement {
	return ReferencesSearch{}.search(element)
}

struct ReferencesSearch {}

pub fn (r &ReferencesSearch) search(element psi.PsiElement) []psi.PsiElement {
	resolved := resolve_identifier(element) or { return [] }
	if resolved is psi.VarDefinition {
		// variables cannot be used outside the scope where they are defined
		scope := element.parent_of_type(.block) or { return [] }
		return r.search_in_scope(resolved, scope)
	}
	if resolved is psi.ParameterDeclaration {
		// TODO: support closure parameters
		parent := resolved.parent_of_type(.function_declaration) or { return [] }
		return r.search_in_scope(resolved, parent)
	}
	if resolved is psi.Receiver {
		parent := resolved.parent_of_type(.function_declaration) or { return [] }
		return r.search_in_scope(resolved, parent)
	}
	return []
}

pub fn (r &ReferencesSearch) search_in_scope(element psi.PsiNamedElement, scope psi.PsiElement) []psi.PsiElement {
	name := element.name()
	mut result := []psi.PsiElement{cap: 10}
	if identifier := element.identifier() {
		result << identifier
	}

	// looking for all references to a variable inside the scope
	for node in psi.new_psi_tree_walker(scope) {
		if node is psi.ReferenceExpression {
			if node.text_matches(name) {
				resolved := node.resolve() or { continue }
				if resolved.is_equal(element as psi.PsiElement) {
					result << node
				}
			}
		}
	}

	return result
}

fn resolve_identifier(element psi.PsiElement) ?psi.PsiElement {
	parent := element.parent() or { return none }
	resolved := if parent is psi.ReferenceExpression {
		parent.resolve() or { return none }
	} else if parent is psi.TypeReferenceExpression {
		parent.resolve() or { return none }
	} else {
		parent
	}

	return resolved
}
