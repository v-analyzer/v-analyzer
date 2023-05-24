module lserver

import lsp
import analyzer.psi
import analyzer.parser

struct CompletionProcessor {
mut:
	result []lsp.CompletionItem
}

fn (mut c CompletionProcessor) execute(element psi.PsiElement) bool {
	if element is psi.VarDefinition {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .variable
			detail: element.get_type().readable_name()
			documentation: ''
			insert_text: element.name()
			insert_text_format: .plain_text
		}
	}

	if element is psi.FunctionOrMethodDeclaration {
		receiver_text := if receiver := element.receiver() {
			receiver.get_text() + ' '
		} else {
			''
		}

		signature := element.signature() or { return true }
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .function
			detail: 'fn ${receiver_text}${element.name()}${signature.get_text()}'
			documentation: element.doc_comment()
			insert_text: element.name() + '($1)$0'
			insert_text_format: .snippet
		}
	}

	if element is psi.StructDeclaration {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .struct_
			detail: ''
			documentation: element.doc_comment()
			insert_text: element.name() + '{$1}$0'
			insert_text_format: .snippet
		}
	}

	if element is psi.ConstantDefinition {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .constant
			detail: element.get_type().readable_name()
			documentation: element.doc_comment()
			insert_text: element.name()
			insert_text_format: .plain_text
		}
	}

	if element is psi.FieldDeclaration {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .field
			detail: element.get_type().readable_name()
			documentation: ''
			insert_text: element.name()
			insert_text_format: .plain_text
		}
	}

	if element is psi.EnumFieldDeclaration {
		c.result << lsp.CompletionItem{
			label: element.name()
			kind: .enum_member
			detail: ''
			documentation: ''
			insert_text: element.name()
			insert_text_format: .plain_text
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

	mut source := file.psi_file.source_text
	source = insert_to_string(source, offset, 'spavnAnalyzerRulezzz')

	res := parser.parse_code(source)
	patched_psi_file := psi.new_psi_file(uri.path(), res.tree, res.source_text)

	element := patched_psi_file.root().find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return []
	}

	mut processor := CompletionProcessor{}

	if parent := element.parent() {
		if parent is psi.TypeReferenceExpression {
			sub := psi.SubResolver{
				containing_file: parent.containing_file
				element: parent
				for_types: false
			}

			sub.process_resolve_variants(mut processor)
		}
		if parent is psi.ReferenceExpression {
			sub := psi.SubResolver{
				containing_file: parent.containing_file
				element: parent
				for_types: false
			}

			sub.process_resolve_variants(mut processor)
		}
	}

	// block := element.parent_of_type_or_self(.block) or { return [] }
	// if block is psi.Block {
	// 	block.process_declarations(mut processor)
	// }

	unsafe { res.tree.free() }

	return processor.result
}

fn insert_to_string(str string, offset u32, insert string) string {
	return str[..offset] + insert + str[offset..]
}
