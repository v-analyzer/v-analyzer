module search

import analyzer.psi
import analyzer.parser
import runtime
import math
import time

[params]
pub struct SearchParams {
	// include_declaration indicates whether to include the declaration
	// of the symbol in the search results
	// This is useful when we want to find all usages of a symbol for
	// refactoring purposes, for example, rename a symbol.
	include_declaration bool
}

pub fn references(element psi.PsiElement, params SearchParams) []psi.PsiElement {
	return ReferencesSearch{
		params: params
	}.search(element)
}

struct ReferencesSearch {
	params SearchParams
}

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
	if resolved is psi.ImportName {
		import_spec := resolved.parent_of_type(.import_spec) or { return [] }
		if import_spec is psi.ImportSpec {
			root := element.containing_file.root
			return r.search_in_scope(import_spec, root)
		}
		return []
	}
	if resolved is psi.ModuleClause {
		return r.search_module_import(resolved)
	}
	if resolved is psi.PsiNamedElement {
		identifier := resolved.identifier() or { return [] }
		return r.search_named_element(resolved, identifier)
	}
	return []
}

pub fn (r &ReferencesSearch) search_module_import(element psi.PsiNamedElement) []psi.PsiElement {
	mut result := []psi.PsiElement{cap: 10}
	file_sink := (element as psi.PsiElement).containing_file.index_sink() or { return [] }
	module_name := file_sink.module_name
	depends_sinks := stubs_index.get_all_sink_depends_on(module_name)

	for sink in depends_sinks {
		root := sink.stub_list.index_map[0] or { continue }
		children := root.children_stubs()
		for child in children {
			if child.stub_type() == .import_list {
				declarations := child.children_stubs()
				for declaration in declarations {
					import_spec := declaration.first_child() or { continue }
					import_path := import_spec.first_child() or { continue }
					if import_path.stub_type() == .import_path {
						if import_path.text() == module_name {
							result << import_path.get_psi() or { continue }
						}
					}
				}
			}
		}
	}

	return result
}

pub fn (r &ReferencesSearch) search_named_element(element psi.PsiNamedElement, identifier psi.PsiElement) []psi.PsiElement {
	is_public := element.is_public()
	is_field := element is psi.FieldDeclaration
	if is_public || is_field {
		return r.search_public_named_element(element, identifier)
	} else {
		return r.search_private_named_element(element, identifier)
	}
}

pub fn (r &ReferencesSearch) search_private_named_element(element psi.PsiNamedElement, identifier psi.PsiElement) []psi.PsiElement {
	module_name := (element as psi.PsiElement).containing_file.module_fqn()
	return r.search_named_element_in_module(module_name, identifier)
}

pub fn (r &ReferencesSearch) search_named_element_in_module(module_name string, identifier psi.PsiElement) []psi.PsiElement {
	mut result := []psi.PsiElement{cap: 10}
	if r.params.include_declaration {
		result << identifier
	}

	sinks_to_search := stubs_index.get_all_sinks_from_module(module_name)
	if sinks_to_search.len == 0 {
		return []
	}

	mut path_to_search := []string{cap: sinks_to_search.len}
	for sink in sinks_to_search {
		path_to_search << sink.stub_list.path
	}

	cpus := runtime.nr_cpus()
	workers := math.max(cpus - 2, 1)
	parsed_files := parser.parse_batch_files(path_to_search, workers)

	for parsed_file in parsed_files {
		psi_file := psi.new_psi_file(parsed_file.path, parsed_file.tree, parsed_file.source_text)
		result << r.search_in(identifier, psi_file.root)
	}

	return result
}

pub fn (r &ReferencesSearch) search_public_named_element(element psi.PsiNamedElement, identifier psi.PsiElement) []psi.PsiElement {
	file_sink := (element as psi.PsiElement).containing_file.index_sink() or { return [] }
	module_name := file_sink.module_name

	// we don't want to search symbol usages in the same module where it is defined
	// if this is not a workspace module
	usages_in_own_module := if file_sink.kind == .workspace {
		r.search_named_element_in_module(module_name, identifier)
	} else {
		[]psi.PsiElement{}
	}

	mut files := []string{cap: 10}
	depends_sinks := stubs_index.get_all_sink_depends_on(module_name)
	for sink in depends_sinks {
		if sink.kind != .workspace {
			continue
		}

		files << sink.stub_list.path
	}

	mut usages_in_depends_modules := []psi.PsiElement{cap: 10}
	cpus := runtime.nr_cpus()
	workers := math.max(cpus - 2, 1)

	watch := time.new_stopwatch(auto_start: true)
	parsed_files := parser.parse_batch_files(files, workers)
	for parsed_result in parsed_files {
		psi_file := psi.new_psi_file(parsed_result.path, parsed_result.tree, parsed_result.source_text)
		usages_in_depends_modules << r.search_in(identifier, psi_file.root)
	}
	println('searching in depends modules took: ${watch.elapsed()}')

	mut all_usages := []psi.PsiElement{cap: usages_in_own_module.len + usages_in_depends_modules.len}
	all_usages << usages_in_own_module
	all_usages << usages_in_depends_modules
	return all_usages
}

pub fn (r &ReferencesSearch) search_in_scope(element psi.PsiNamedElement, scope psi.PsiElement) []psi.PsiElement {
	mut result := []psi.PsiElement{cap: 10}
	identifier := element.identifier() or { return [] }
	if r.params.include_declaration {
		result << identifier
	}

	// looking for all references to a variable inside the scope
	result << r.search_in(identifier, scope)

	return result
}

pub fn (r &ReferencesSearch) search_in(element_identifier psi.PsiElement, search_root psi.PsiElement) []psi.PsiElement {
	name := element_identifier.get_text()
	mut result := []psi.PsiElement{cap: 10}
	for node in psi.new_psi_tree_walker(search_root) {
		if node is psi.ReferenceExpression || node is psi.TypeReferenceExpression {
			ref := node as psi.ReferenceExpressionBase
			if node.text_matches(name) {
				resolved := ref.resolve() or { continue }
				if resolved is psi.PsiNamedElement {
					if resolved.identifier_text_range() == element_identifier.text_range() {
						result << node
					}
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
