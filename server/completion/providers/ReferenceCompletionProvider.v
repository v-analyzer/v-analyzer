module providers

import analyzer.psi
import server.completion

pub struct ReferenceCompletionProvider {
pub mut:
	processor &ReferenceCompletionProcessor
}

fn (r &ReferenceCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_expression || ctx.is_type_reference
}

fn (mut r ReferenceCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	element := ctx.element
	text := element.get_text()
	if text.starts_with('@') {
		// See `CompileTimeConstantCompletionProvider`
		return
	}

	parent := element.parent() or { return }

	if parent is psi.TypeReferenceExpression {
		sub := psi.SubResolver{
			containing_file: parent.containing_file
			element: parent
			for_types: true
		}

		sub.process_resolve_variants(mut r.processor)
	}

	if parent is psi.ReferenceExpression {
		sub := psi.SubResolver{
			containing_file: parent.containing_file
			element: parent
			for_types: false
		}

		sub.process_resolve_variants(mut r.processor)
	}
}
