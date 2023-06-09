module lserver

import lsp
import lserver.semantic
import time

pub fn (mut ls LanguageServer) semantic_tokens_full(params lsp.SemanticTokensParams, mut wr ResponseWriter) ?lsp.SemanticTokens {
	if ls.cfg.enable_semantic_tokens == .none_ {
		return none
	}

	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	lines := file.psi_file.source_text.count('\n')

	if lines > 1000 || ls.cfg.enable_semantic_tokens == .syntax {
		// We don't want to send too many tokens, so we just send dumb-aware tokens for large files.
		mut dumb_aware_visitor := semantic.DumbAwareSemanticVisitor{}
		res := semantic.encode(dumb_aware_visitor.accept(file.psi_file.root))

		return lsp.SemanticTokens{
			result_id: time.now().unix_time().str()
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
		result_id: time.now().unix_time().str()
		data: semantic.encode(result)
	}
}
