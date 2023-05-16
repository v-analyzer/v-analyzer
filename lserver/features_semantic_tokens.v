module lserver

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) semantic_tokens_full(params lsp.SemanticTokensParams, mut wr ResponseWriter) ?lsp.SemanticTokens {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	if file.psi_file.source_text.len() > 5000 {
		return none
	}

	mut visitor := SemanticVisitor{}
	file.psi_file.root.accept_mut(mut visitor)
	res := visitor.encode()

	return lsp.SemanticTokens{
		result_id: '0'
		data: res
	}
}

struct SemanticToken {
	line  u32
	start u32
	len   u32
	typ   string
	mods  []string
}

const sql_keywords = {
	'from':   true
	'where':  true
	'limit':  true
	'insert': true
	'update': true
}

struct SemanticVisitor {
mut:
	result []SemanticToken = []SemanticToken{cap: 100}
}

fn (mut f SemanticVisitor) visit_element(element psi.PsiElement) {
	if !f.visit_element_impl(element) {
		return
	}
	mut child := element.first_child() or { return }
	for {
		child.accept_mut(mut f)
		child = child.next_sibling() or { break }
	}
}

fn element_to_semantic(element psi.AstNode, typ string, modifiers ...string) SemanticToken {
	start_point := element.start_point()
	return SemanticToken{
		line: start_point.row
		start: start_point.column
		len: element.text_length()
		typ: typ
		mods: modifiers
	}
}

fn (mut f SemanticVisitor) visit_element_impl(element psi.PsiElement) bool {
	if element.node.type_name == .struct_field_declaration {
		if first_child := element.node.first_child() {
			f.result << element_to_semantic(first_child, 'property')
		}
	}

	if element.node.type_name == .module_clause {
		if last_child := element.node.last_child() {
			f.result << element_to_semantic(last_child, 'namespace')
		}
	}

	if element.node.type_name == .field_name {
		f.result << element_to_semantic(element.node, 'property')
	}

	if element.node.type_name == .parameter_declaration || element.node.type_name == .receiver {
		is_mut := if _ := element.node.child_by_field_name('mutability') {
			true
		} else {
			false
		}

		if identifier := element.node.child_by_field_name('name') {
			mut mods := []string{}
			if is_mut {
				mods << 'mutable'
			}
			f.result << element_to_semantic(identifier, 'parameter', ...mods)
		}
	}

	if element.node.type_name == .var_definition {
		f.result << element_to_semantic(element.node, 'variable')
	}

	if element.node.type_name == .reference_expression
		|| element.node.type_name == .type_reference_expression {
		if element is psi.PsiElementImpl {
			ref := psi.ReferenceExpression{
				PsiElementImpl: element
			}.reference()
			if res := ref.resolve() {
				if first_child := element.node.first_child() {
					if res is psi.VarDefinition {
						mut mods := []string{}
						if res.is_mutable() {
							mods << 'mutable'
						}
						f.result << element_to_semantic(first_child, 'variable', ...mods)
					} else if res is psi.ConstantDefinition {
						f.result << element_to_semantic(first_child, 'property')
					} else if res is psi.StructDeclaration {
						f.result << element_to_semantic(first_child, 'struct')
					} else if res is psi.FieldDeclaration {
						f.result << element_to_semantic(first_child, 'property')
					} else if res is psi.ParameterDeclaration {
						mut mods := []string{}
						if res.is_mutable() {
							mods << 'mutable'
						}
						f.result << element_to_semantic(first_child, 'parameter', ...mods)
					} else if res is psi.Receiver {
						mut mods := []string{}
						if res.is_mutable() {
							mods << 'mutable'
						}
						f.result << element_to_semantic(first_child, 'parameter', ...mods)
					}
				}
			}
		}
	}

	// if element.node.type_name == .type_reference_expression || element.node.type_name == .reference_expression {
	// 	if parent := element.node.parent() {
	// 		if parent.type_name == .type_selector_expression || parent.type_name == .selector_expression {
	// 			f.result << element_to_semantic(element.node, 'property')
	// 		}
	// 	}
	// }

	if element.node.type_name == .identifier {
		if parent := element.node.parent() {
			if parent.type_name == .attribute_spec {
				f.result << element_to_semantic(element.node, 'decorator')
			}
		}
	}

	if element.node.type_name == .unknown {
		text := element.node.text(element.containing_file.source_text)
		if text == 'mut' {
			f.result << element_to_semantic(element.node, 'keyword')
		}

		if parent := element.node.parent() {
			if text == 'sql' || text in lserver.sql_keywords {
				if parent.type_name == .sql_expression {
					f.result << element_to_semantic(element.node, 'keyword')
				}
			}

			if parent.type_name == .attribute_declaration || parent.type_name == .attribute_spec {
				f.result << element_to_semantic(element.node, 'decorator')
			}
		}
	}

	return true
}

fn (f &SemanticVisitor) encode() []u32 {
	mut result := f.result.clone()
	result.sort_with_compare(fn (left &SemanticToken, right &SemanticToken) int {
		if left.line != right.line {
			if left.line < right.line {
				return -1
			}
			if left.line > right.line {
				return 1
			}
		}
		if left.start < right.start {
			return -1
		}

		if left.start > right.start {
			return 1
		}

		return 0
	})

	mut res := []u32{len: result.len * 5}

	mut cur := 0
	mut last := SemanticToken{}
	for tok in result {
		typ := lserver.semantic_types_by_name[tok.typ] or { continue }
		if cur == 0 {
			res[cur] = tok.line
		} else {
			res[cur] = tok.line - last.line
		}
		res[cur + 1] = tok.start
		if cur > 0 && res[cur] == 0 {
			res[cur + 1] = tok.start - last.start
		}
		res[cur + 2] = tok.len
		res[cur + 3] = typ // for now
		res[cur + 4] = if 'mutable' in tok.mods { u32(0b010000000000) } else { u32(0) }
		cur += 5
		last = tok
	}

	return res[..cur]
}

const (
	semantic_types             = [
		'namespace',
		'type',
		'class',
		'enum',
		'interface',
		'struct',
		'typeParameter',
		'parameter',
		'variable',
		'property',
		'enumMember',
		'event',
		'function',
		'method',
		'macro',
		'keyword',
		'modifier',
		'comment',
		'string',
		'number',
		'regexp',
		'operator',
		'decorator',
	]
	semantic_modifiers         = [
		'declaration',
		'definition',
		'readonly',
		'static',
		'deprecated',
		'abstract',
		'async',
		'modification',
		'documentation',
		'defaultLibrary',
		'mutable',
	]

	semantic_types_by_name     = build_semantic_types_map()
	semantic_modifiers_by_name = build_semantic_modifiers_map()
)

fn build_semantic_types_map() map[string]u32 {
	mut res := map[string]u32{}
	for i, semantic_type in lserver.semantic_types {
		res[semantic_type] = u32(i)
	}
	return res
}

fn build_semantic_modifiers_map() map[string]u32 {
	mut res := map[string]u32{}
	for i, semantic_modifier in lserver.semantic_modifiers {
		res[semantic_modifier] = u32(i)
	}
	return res
}
