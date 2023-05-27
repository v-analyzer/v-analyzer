module providers

import analyzer.psi
import lserver.completion
import lsp

pub struct ModulesImportProvider {}

fn (m &ModulesImportProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	return parent is psi.ImportName
}

fn (mut m ModulesImportProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	element := ctx.element
	parent_path := element.parent_nth(2) or { return }
	before_path := parent_path.get_text().trim_string_right('spavnAnalyzerRulezzz')

	modules := psi.get_all_modules()

	for module_ in modules {
		if !module_.starts_with(before_path) {
			continue
		}
		name_without_prefix := module_.trim_string_left(before_path)

		result.add_element(lsp.CompletionItem{
			label: name_without_prefix
			kind: .module_
			detail: ''
			documentation: ''
			insert_text: name_without_prefix
			insert_text_format: .plain_text
		})
	}
}
