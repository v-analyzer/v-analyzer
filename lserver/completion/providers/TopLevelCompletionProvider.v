module providers

import analyzer.psi
import lserver.completion
import lsp

const top_level_map = {
	'fn name() { ... }':       'fn \${1:name}($2) {\n\t$0\n}'
	'struct Name { ... }':     'struct \${1:Name} {\n\t$0\n}'
	'interface IName { ... }': 'interface \${1:IName} {\n\t$0\n}'
	'enum Colors { ... }':     'enum \${1:Colors} {\n\t$0\n}'
	'type MyString = string':  'type \${1:MyString} = \${2:string}$0'
	'сonst secret = 100':      'const \${1:secret} = \${2:100}$0'
}

pub struct TopLevelCompletionProvider {}

fn (k &TopLevelCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent_nth(3) or { return false }
	if parent.node.type_name != .source_file {
		return false
	}
	return true
}

fn (mut k TopLevelCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	k.pub_keyword(mut result)
}

fn (mut k TopLevelCompletionProvider) pub_keyword(mut result completion.CompletionResultSet) {
	for label, insert_text in providers.top_level_map {
		result.add_element(lsp.CompletionItem{
			label: label
			kind: .keyword
			insert_text: insert_text
			insert_text_format: .snippet
		})
	}

	for label, insert_text in providers.top_level_map {
		result.add_element(lsp.CompletionItem{
			label: 'pub ${label}'
			kind: .keyword
			insert_text: 'pub ${insert_text}'
			insert_text_format: .snippet
		})
	}
}
