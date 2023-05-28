module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct PureBlockExpressionCompletionProvider {}

fn (k &PureBlockExpressionCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut k PureBlockExpressionCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	one_line := if parent := ctx.element.parent_nth(2) {
		if parent.node.type_name == .simple_statement {
			false
		} else {
			true
		}
	} else {
		true
	}

	insert_text := if one_line {
		'unsafe { $0 }'
	} else {
		'unsafe {\n\t$0\n}'
	}

	result.add_element(lsp.CompletionItem{
		label: 'unsafe { ... }'
		kind: .keyword
		insert_text: insert_text
		insert_text_format: .snippet
		insert_text_mode: .adjust_indentation
	})
}
