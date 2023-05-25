module lserver

import lsp
import lserver.semantic

pub fn (mut ls LanguageServer) semantic_tokens_full(params lsp.SemanticTokensParams, mut wr ResponseWriter) ?lsp.SemanticTokens {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	mut visitor := semantic.DumbAwareSemanticVisitor{}
	res := semantic.encode(visitor.accept(file.psi_file.root))

	return lsp.SemanticTokens{
		result_id: '0'
		data: res
	}
}
