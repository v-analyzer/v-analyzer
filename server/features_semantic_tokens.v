// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module server

import lsp
import server.semantic
import time

const max_line_for_resolve_semantic_tokens = 1000

const max_line_for_any_semantic_tokens = 10000

pub fn (mut ls LanguageServer) semantic_tokens(text_document lsp.TextDocumentIdentifier, range lsp.Range) ?lsp.SemanticTokens {
	if ls.cfg.enable_semantic_tokens == .none_ {
		return none
	}

	uri := text_document.uri.normalize()
	file := ls.get_file(uri)?

	lines := file.psi_file.source_text.count('\n')

	if lines > server.max_line_for_any_semantic_tokens {
		// File too large, don't compute any tokens.
		return lsp.SemanticTokens{}
	}

	if lines > server.max_line_for_resolve_semantic_tokens
		|| ls.cfg.enable_semantic_tokens == .syntax {
		// We don't want to send too many tokens (and compute it), so we just
		// send dumb-aware tokens for large files.
		dumb_aware_visitor := semantic.new_dumb_aware_semantic_visitor(range, file.psi_file)
		tokens := dumb_aware_visitor.accept(file.psi_file.root)
		return lsp.SemanticTokens{
			result_id: time.now().unix_time().str()
			data: semantic.encode(tokens)
		}
	}

	mut result := semantic.new_dumb_aware_semantic_visitor(range, file.psi_file)
		.accept(file.psi_file.root)
	resolve_tokens := semantic.new_resolve_semantic_visitor(range, file.psi_file)
		.accept(file.psi_file.root)

	result << resolve_tokens

	return lsp.SemanticTokens{
		result_id: time.now().unix_time().str()
		data: semantic.encode(result)
	}
}
