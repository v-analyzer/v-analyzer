module lserver

import lsp
import lserver.semantic

pub fn (mut ls LanguageServer) semantic_tokens_full(params lsp.SemanticTokensParams, mut wr ResponseWriter) ?lsp.SemanticTokens {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	lines := file.psi_file.source_text.count('\n')

	if lines > 500 {
		mut dumb_aware_visitor := semantic.DumbAwareSemanticVisitor{}
		res := semantic.encode(dumb_aware_visitor.accept(file.psi_file.root))

		return lsp.SemanticTokens{
			result_id: '0'
			data: res
		}
	}

	mut dumb_aware_visitor := semantic.DumbAwareSemanticVisitor{}
	dumb_aware_tokens := dumb_aware_visitor.accept(file.psi_file.root)

	resolve_visitor := semantic.ResolveSemanticVisitor{}
	resolve_tokens := resolve_visitor.accept(file.psi_file.root)

	mut result := []semantic.SemanticToken{cap: dumb_aware_tokens.len + resolve_tokens.len}
	result << dumb_aware_tokens
	result << resolve_tokens

	return lsp.SemanticTokens{
		result_id: '0'
		data: semantic.encode(result)
	}
}
