module lserver

import lsp
import os
import analyzer.parser
import analyzer.indexer

pub fn (mut ls LanguageServer) completion(params lsp.CompletionParams, mut wr ResponseWriter) ![]lsp.CompletionItem {
	content := os.read_file(params.text_document.uri.path())!
	res := parser.parse_code(content)

	// lines := content.split_into_lines()
	// lines_offset := lines[..params.position.line].join('\n').len + params.position.character

	symbols := ls.analyzer_instance.index.index.data.get_all_functions()

	// symbols := ls.analyzer_instance.index.index.data.get_all_symbols()

	return symbols
		.filter(it.module_fqn == '')
		.filter(it.name != '')
		.map(fn (it indexer.FunctionCache) lsp.CompletionItem {
			return lsp.CompletionItem{
				label: it.name
				kind: .function
				detail: 'Some detail'
				documentation: 'some documentation'
				insert_text: it.name + '()'
				insert_text_format: .plain_text
			}
		})
}
