module hints

import lsp
import analyzer.psi
import config

pub struct InlayHintsVisitor {
	cfg config.InlayHintsConfig
pub mut:
	result []lsp.InlayHint = []lsp.InlayHint{cap: 1000}
}

pub fn (mut v InlayHintsVisitor) accept(root psi.PsiElement) {
	for node in psi.new_tree_walker(root.node) {
		v.process_node(node, root.containing_file)
	}
}

[inline]
pub fn (mut v InlayHintsVisitor) process_node(node psi.AstNode, containing_file &psi.PsiFileImpl) {
	if node.type_name == .range && v.cfg.enable_range_hints {
		operator := node.child_by_field_name('operator') or { return }
		start_point := operator.start_point()
		end_point := operator.end_point()

		v.result << lsp.InlayHint{
			position: lsp.Position{
				line: int(start_point.row)
				character: int(start_point.column)
			}
			label: '≤'
			kind: .type_
		}
		v.result << lsp.InlayHint{
			position: lsp.Position{
				line: int(end_point.row)
				character: int(end_point.column)
			}
			label: '<'
			kind: .type_
		}
		return
	}

	if v.cfg.enable_type_hints {
		def := psi.node_to_var_definition(node, containing_file, none)
		if !isnil(def) {
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

	if node.type_name == .or_block && v.cfg.enable_implicit_err_hints {
		block := node.child_by_field_name('block') or { return }
		v.handle_implicit_error_variable(block)
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
		label: 'err →'
		kind: .parameter
	}
}
