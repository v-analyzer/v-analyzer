module providers

import analyzer.psi
import lserver.completion
import lsp
import utils

pub struct JsonAttributeCompletionProvider {}

fn (k &JsonAttributeCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	if !ctx.is_attribute {
		return false
	}
	return ctx.element.inside(.struct_field_declaration)
}

fn (mut k JsonAttributeCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	field_declaration := ctx.element.parent_of_type(.struct_field_declaration) or { return }
	name := if field_declaration is psi.FieldDeclaration {
		field_declaration.name()
	} else {
		return
	}

	camel_case_name := utils.snake_case_to_camel_case(name)

	result.add_element(lsp.CompletionItem{
		label: "json: '${camel_case_name}'"
		kind: .keyword
		insert_text: "json: '\${1:${camel_case_name}}'$0"
		insert_text_format: .snippet
	})
}
