module providers

import analyzer.psi
import lserver.completion
import lsp
import os

pub struct ModuleNameCompletionProvider {}

fn (_ &ModuleNameCompletionProvider) is_available(context psi.PsiElement) bool {
	line := context.text_range().line
	if line > 2 {
		return false
	}
	parent := context.parent_nth(3) or { return false }
	if parent.node.type_name != .source_file {
		return false
	}
	return true
}

fn (mut p ModuleNameCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	dir := os.dir(ctx.element.containing_file.path)
	dir_name := p.transform_module_name(os.file_name(dir))

	result.add_element(lsp.CompletionItem{
		label: 'module ${dir_name}'
		kind: .keyword
		insert_text_format: .snippet
		insert_text: 'module ${dir_name}'
	})

	result.add_element(lsp.CompletionItem{
		label: 'module main'
		kind: .keyword
		insert_text: 'module main'
	})
}

fn (mut _ ModuleNameCompletionProvider) transform_module_name(raw_name string) string {
	return raw_name
		.replace('-', '_')
		.replace(' ', '_')
		.to_lower()
}
