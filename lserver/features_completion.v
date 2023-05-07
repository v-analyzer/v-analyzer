module lserver

import lsp
import analyzer.psi

struct CompletionProcessor {
mut:
	result []lsp.CompletionItem
}

fn (mut c CompletionProcessor) execute(element psi.PsiElement) bool {
	if element is psi.VarDefinition {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .variable
			detail: 'Some detail'
			documentation: ''
			insert_text: element.name()
			insert_text_format: .plain_text
		}
	}

	if element is psi.FunctionDeclaration {
		signature := element.signature() or { return true }
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .function
			detail: 'fn ${element.name()}${signature.get_text()}'
			documentation: element.doc_comment()
			insert_text: element.name() + '($1)$0'
			insert_text_format: .snippet
		}
	}

	if element is psi.StructDeclaration {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .class
			detail: 'Some detail'
			documentation: ''
			insert_text: element.name() + '{$1}$0'
			insert_text_format: .snippet
		}
	}

	return true
}

pub fn (mut ls LanguageServer) completion(params lsp.CompletionParams, mut wr ResponseWriter) ![]lsp.CompletionItem {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or {
		println('cannot find file ' + uri.str())
		return []
	}

	offset := file.find_offset(params.position)
	element := file.psi_file.find_most_depth_element_at(offset - 1) or {
		println('cannot find element at ' + offset.str())
		return []
	}

	mut processor := CompletionProcessor{}

	block := element.parent_of_type_or_self(.block) or { return [] }
	if block is psi.Block {
		block.process_declarations(mut processor)
	}

	file.psi_file.process_declarations(mut processor)

	return processor.result
}
