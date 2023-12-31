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
module lsp

pub struct SemanticTokens {
pub:
	// An optional result id. If provided and clients support delta updating
	// the client will include the result id in the next semantic token request.
	// A server can then instead of computing all semantic tokens again simply
	// send a delta.
	result_id string @[json: 'resultID']
	// The actual tokens.
	data []u32
}

pub struct SemanticTokensOptions {
pub:
	// The legend used by the server
	legend SemanticTokensLegend
	// Server supports providing semantic tokens for a specific range
	// of a document.
	range bool @[omitempty]
	// Server supports providing semantic tokens for a full document.
	full bool @[omitempty]
}

pub struct SemanticTokensLegend {
pub:
	// The token types a server uses.
	token_types []string @[json: 'tokenTypes']
	// The token modifiers a server uses.
	token_modifiers []string @[json: 'tokenModifiers']
}

pub struct SemanticTokensParams {
pub:
	// The text document.
	text_document TextDocumentIdentifier @[json: 'textDocument']
}

pub struct SemanticTokensRangeParams {
pub:
	// The text document.
	text_document TextDocumentIdentifier @[json: 'textDocument']
	// The range the semantic tokens are requested for.
	range Range @[omitempty]
}
