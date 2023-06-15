module hints

import lsp
import config
import analyzer.psi
import analyzer.psi.types

pub struct InlayHintsVisitor {
	cfg config.InlayHintsConfig
pub mut:
	lines  int
	result []lsp.InlayHint = []lsp.InlayHint{cap: 1000}
}

pub fn (mut v InlayHintsVisitor) accept(root psi.PsiElement) {
	v.lines = root.containing_file.source_text.count('\n')

	for node in psi.new_tree_walker(root.node) {
		v.process_node(node, root.containing_file)
	}
}

pub fn (mut v InlayHintsVisitor) process_node(node psi.AstNode, containing_file &psi.PsiFile) {
	if node.type_name == .range && v.cfg.enable_range_hints {
		operator := node.child_by_field_name('operator') or { return }
		start_point := operator.start_point()
		end_point := operator.end_point()

		need_left := if _ := node.child_by_field_name('start') { true } else { false }
		need_right := if _ := node.child_by_field_name('end') { true } else { false }

		if need_left {
			v.result << lsp.InlayHint{
				position: lsp.Position{
					line: int(start_point.row)
					character: int(start_point.column)
				}
				label: '≤'
				kind: .type_
			}
		}
		if need_right {
			v.result << lsp.InlayHint{
				position: lsp.Position{
					line: int(end_point.row)
					character: int(end_point.column)
				}
				label: '<'
				kind: .type_
			}
		}
		return
	}

	if v.cfg.enable_type_hints {
		def := psi.node_to_var_definition(node, containing_file, none)
		if !isnil(def) && def.name() != '_' {
			typ := def.get_type()
			range := def.text_range()

			v.result << lsp.InlayHint{
				position: lsp.Position{
					line: range.line
					character: range.end_column
				}
				label: ': ' + typ.readable_name()
				kind: .type_
			}
		}
	}

	if node.type_name == .or_block_expression && v.cfg.enable_implicit_err_hints {
		expression_node := node.first_child() or { return }
		expression := psi.create_element(expression_node, containing_file)
		typ := psi.infer_type(expression)
		if typ !is types.ResultType {
			// show `err ->` hint only for `Result` type
			return
		}

		or_block := node.last_child() or { return }
		block := or_block.child_by_field_name('block') or { return }
		v.handle_implicit_error_variable(block)
	}

	if node.type_name == .call_expression && v.cfg.enable_parameter_name_hints {
		v.handle_call_expression(node, containing_file)
	}
}

pub fn (mut v InlayHintsVisitor) handle_call_expression(call psi.AstNode, containing_file &psi.PsiFile) {
	if v.lines > 1000 {
		// don't show this hints for large files
		return
	}

	call_expression := psi.create_element(call, containing_file)
	if call_expression is psi.CallExpression {
		arguments := call_expression.arguments()
		called := call_expression.resolve() or { return }
		if called is psi.SignatureOwner {
			signature := called.signature() or { return }
			for i, param in signature.parameters() {
				name := if param is psi.ParameterDeclaration { param.name() } else { '_' }
				if name == '_' {
					continue
				}

				arg := arguments[i] or { continue }
				if arg.node.type_name == .keyed_element {
					// don't show hint for named arguments
					continue
				}

				arg_inner := if arg.node.type_name == .mutable_expression {
					arg.last_child() or { continue }
				} else {
					arg
				}
				if arg_inner.text_matches(name) {
					// don't show hint if argument name matches parameter name
					continue
				}

				arg_range := arg.text_range()
				v.result << lsp.InlayHint{
					position: lsp.Position{
						line: arg_range.line
						character: arg_range.column
					}
					label: '${name}: '
					kind: .parameter
				}
			}
		}
	}
}

pub fn (mut v InlayHintsVisitor) handle_implicit_error_variable(block psi.AstNode) {
	start_point := block.start_point()
	end_point := block.end_point()

	if start_point.row == end_point.row {
		// don't show hint if 'or { ... }'
		return
	}

	v.result << lsp.InlayHint{
		position: lsp.Position{
			line: int(start_point.row)
			character: int(start_point.column + 1)
		}
		label: ' err →'
		kind: .parameter
	}
}
