module lserver

import lsp
import analyzer.psi
import analyzer.parser
import lserver.completion
import lserver.completion.providers

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

	mut ctx := &completion.CompletionContext{
		element: element
		position: params.position
		offset: offset
		trigger_kind: params.context.trigger_kind
	}
	ctx.compute()

	mut result_set := &completion.CompletionResultSet{}

	mut processor := &providers.ReferenceCompletionProcessor{
		file: file.psi_file
		module_fqn: file.psi_file.module_fqn()
	}

	mut completion_providers := []completion.CompletionProvider{}
	completion_providers << providers.ReferenceCompletionProvider{
		processor: processor
	}
	completion_providers << providers.ModulesImportProvider{}
	completion_providers << providers.ReturnCompletionProvider{}
	completion_providers << providers.CompileTimeConstantCompletionProvider{}
	completion_providers << providers.InitsCompletionProvider{}
	completion_providers << providers.KeywordsCompletionProvider{}
	completion_providers << providers.TopLevelCompletionProvider{}
	completion_providers << providers.LoopKeywordsCompletionProvider{}
	completion_providers << providers.PureBlockExpressionCompletionProvider{}
	completion_providers << providers.PureBlockStatementCompletionProvider{}
	completion_providers << providers.OrBlockExpressionCompletionProvider{}
	completion_providers << providers.FunctionLikeCompletionProvider{}
	completion_providers << providers.AssertCompletionProvider{}
	completion_providers << providers.ModuleNameCompletionProvider{}
	completion_providers << providers.NilKeywordCompletionProvider{}
	completion_providers << providers.JsonAttributeCompletionProvider{}
	completion_providers << providers.AttributesCompletionProvider{}

	for mut provider in completion_providers {
		if !provider.is_available(ctx) {
			continue
		}
		provider.add_completion(ctx, mut result_set)
	}

	for el in processor.elements() {
		result_set.add_element(el)
	}

	unsafe { res.tree.free() }

	return result_set.elements()
}

fn insert_to_string(str string, offset u32, insert string) string {
	return str[..offset] + insert + str[offset..]
}
