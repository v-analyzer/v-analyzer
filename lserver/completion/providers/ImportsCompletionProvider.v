module providers

import lserver.completion
import lsp

pub struct ImportsCompletionProvider {}

fn (_ &ImportsCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_expression && !ctx.after_dot
}

fn (mut _ ImportsCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	file := ctx.element.containing_file

	imports := file.get_imports()
	imports_names := imports.map(it.import_name())

	for import_name in imports_names {
		result.add_element(lsp.CompletionItem{
			label: import_name
			kind: .module_
			insert_text: '${import_name}.'
		})
	}
}
