module server

import lsp
import server.semantic
import time

const (
	max_line_for_resolve_semantic_tokens = 1000
	max_line_for_any_semantic_tokens     = 10000
)

pub fn (mut ls LanguageServer) semantic_tokens(text_document lsp.TextDocumentIdentifier, range lsp.Range, mut wr ResponseWriter) ?lsp.SemanticTokens {
	if ls.cfg.enable_semantic_tokens == .none_ {
		return none
	}

	uri := text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	lines := file.psi_file.source_text.count('\n')

	if lines > server.max_line_for_any_semantic_tokens {
		// File too large, don't compute any tokens.
		return lsp.SemanticTokens{}
	}

	if lines > server.max_line_for_resolve_semantic_tokens
		|| ls.cfg.enable_semantic_tokens == .syntax {
		// We don't want to send too many tokens, so we just send dumb-aware tokens for large files.
		dumb_aware_visitor := semantic.new_dumb_aware_semantic_visitor(range, file.psi_file)
		return lsp.SemanticTokens{
			result_id: time.now().unix_time().str()
			data: semantic.encode(dumb_aware_visitor.accept(file.psi_file.root))
		}
	}

	dumb_aware_visitor := semantic.new_dumb_aware_semantic_visitor(range, file.psi_file)
	dumb_aware_tokens := dumb_aware_visitor.accept(file.psi_file.root)

	resolve_visitor := semantic.new_resolve_semantic_visitor(range, file.psi_file)
	resolve_tokens := resolve_visitor.accept(file.psi_file.root)

	mut result := []semantic.SemanticToken{cap: dumb_aware_tokens.len + resolve_tokens.len}
	result << dumb_aware_tokens
	result << resolve_tokens

	return lsp.SemanticTokens{
		result_id: time.now().unix_time().str()
		data: semantic.encode(result)
	}
}
