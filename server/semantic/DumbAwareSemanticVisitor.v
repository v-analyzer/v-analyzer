module semantic

import lsp
import utils
import analyzer.psi

// DumbAwareSemanticVisitor is a highly optimized visitor that collects information about
// semantic tokens in a file based only on their syntax tree.
// This annotator must not call resolve or use indexes.
pub struct DumbAwareSemanticVisitor {
	start      u32  // start offset when request range is specified
	end        u32  // end offset when request range is specified
	with_range bool // whether request range is specified
}

pub fn new_dumb_aware_semantic_visitor(range lsp.Range, containing_file &psi.PsiFile) DumbAwareSemanticVisitor {
	start := utils.compute_offset(containing_file.source_text, range.start.line, range.start.character)
	end := utils.compute_offset(containing_file.source_text, range.end.line, range.end.character)

	return DumbAwareSemanticVisitor{
		with_range: !range.is_empty()
		start: u32(start)
		end: u32(end)
	}
}

pub fn (v DumbAwareSemanticVisitor) accept(root psi.PsiElement) []SemanticToken {
	mut result := []SemanticToken{cap: 500}

	for node in psi.new_tree_walker(root.node) {
		range := node.range()
		if v.with_range && (range.end_byte <= v.start || range.start_byte >= v.end) {
			continue
		}

		v.highlight_node(node, root, mut result)
	}

	return result
}

[inline]
fn (_ DumbAwareSemanticVisitor) highlight_node(node psi.AstNode, root psi.PsiElement, mut result []SemanticToken) {
	if node.type_name == .enum_field_definition {
		if first_child := node.first_child() {
			result << element_to_semantic(first_child, .enum_member)
		}
	} else if node.type_name == .field_name {
		result << element_to_semantic(node, .property)
	} else if node.type_name == .struct_field_declaration {
		if first_child := node.first_child() {
			if first_child.type_name != .embedded_definition {
				result << element_to_semantic(first_child, .property)
			}
		}
	} else if node.type_name == .module_clause {
		if last_child := node.last_child() {
			result << element_to_semantic(last_child, .namespace)
		}
	} else if node.type_name == .value_attribute {
		first_child := node.first_child() or { return }
		result << element_to_semantic(first_child, .decorator)
	} else if node.type_name == .attribute {
		// '['
		first_child := node.first_child() or { return }
		// ']'
		last_child := node.last_child() or { return }
		result << element_to_semantic(first_child, .decorator)
		result << element_to_semantic(last_child, .decorator)
	} else if node.type_name == .key_value_attribute {
		value_child := node.child_by_field_name('value') or { return }
		if value_child.type_name == .identifier {
			result << element_to_semantic(node, .decorator)
		}
	} else if node.type_name == .qualified_type {
		first_child := node.first_child() or { return }
		result << element_to_semantic(first_child, .namespace)
	} else if node.type_name == .unknown {
		text := node.text(root.containing_file.source_text)

		if text == 'sql' {
			if parent := node.parent() {
				if parent.type_name == .sql_expression {
					result << element_to_semantic(node, .keyword)
				}
			}
		}
		if text == 'chan' {
			if parent := node.parent() {
				if parent.type_name == .channel_type {
					result << element_to_semantic(node, .keyword)
				}
			}
		}
		if text == 'thread' {
			if parent := node.parent() {
				if parent.type_name == .thread_type {
					result << element_to_semantic(node, .keyword)
				}
			}
		}
	} else if node.type_name == .enum_declaration {
		identifier := node.child_by_field_name('name') or { return }
		result << element_to_semantic(identifier, .enum_)
	} else if node.type_name == .parameter_declaration || node.type_name == .receiver {
		identifier := node.child_by_field_name('name') or { return }
		is_mut := if _ := node.child_by_field_name('mutability') {
			true
		} else {
			false
		}

		mut mods := []string{}
		if is_mut {
			mods << 'mutable'
		}
		result << element_to_semantic(identifier, .parameter, ...mods)
	} else if node.type_name == .reference_expression {
		def := psi.node_to_var_definition(node, root.containing_file, none)
		if !isnil(def) {
			mods := if def.is_mutable() {
				['mutable']
			} else {
				[]string{}
			}

			result << element_to_semantic(node, .variable, ...mods)
		}

		first_char := node.first_char(root.containing_file.source_text)
		if first_char == `@` || first_char == `$` {
			result << element_to_semantic(node, .property) // not a best variant...
		}
	} else if node.type_name == .const_definition {
		name := node.child_by_field_name('name') or { return }
		result << element_to_semantic(name, .property) // not a best variant...
	} else if node.type_name == .import_path {
		if last_part := node.last_child() {
			result << element_to_semantic(last_part, .namespace)
		}
	} else if node.type_name in [.braced_interpolation_opening, .braced_interpolation_closing] {
		result << element_to_semantic(node, .keyword)
	} else if node.type_name == .generic_parameter {
		result << element_to_semantic(node, .type_parameter)
	} else if node.type_name == .global_var_definition {
		identifier := node.child_by_field_name('name') or { return }
		result << element_to_semantic(identifier, .variable, 'global')
	} else if node.type_name == .function_declaration {
		if first_child := node.child_by_field_name('name') {
			first_char := first_child.first_char(root.containing_file.source_text)
			if first_char in [`@`, `$`] {
				// tweak highlighting for @lock/@rlock
				result << element_to_semantic(first_child, .function)
			}
		}
	}

	$if debug {
		// this useful for finding errors in parsing
		if node.type_name == .error {
			result << element_to_semantic(node, .namespace, 'mutable')
		}
	}
}
