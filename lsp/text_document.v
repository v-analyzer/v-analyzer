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

pub struct Position {
pub:
	line      int
	character int
}

pub struct Range {
pub:
	start Position
	end   Position
}

pub fn (r Range) is_empty() bool {
	return r.start.line == 0 && r.end.line == 0 && r.start.character == 0 && r.end.character == 0
}

pub struct TextEdit {
pub:
	range    Range
	new_text string @[json: 'newText']
}

pub struct TextDocumentIdentifier {
pub:
	uri DocumentUri
}

pub struct TextDocumentEdit {
	text_document VersionedTextDocumentIdentifier @[json: textDocument]
	edits         []TextEdit
}

pub struct TextDocumentItem {
pub:
	uri         DocumentUri
	language_id string      @[json: languageId]
	version     int
	text        string
}

pub struct VersionedTextDocumentIdentifier {
pub:
	uri     DocumentUri
	version int
}

pub struct Location {
pub mut:
	uri   DocumentUri
	range Range
}

pub struct LocationLink {
pub:
	// Span of the origin of this link.
	//
	// Used as the underlined span for mouse interaction. Defaults to the word
	// range at the mouse position.
	origin_selection_range Range @[json: 'originSelectionRange']
	// The target resource identifier of this link.
	target_uri DocumentUri @[json: 'targetUri']
	// The full target range of this link. If the target for example is a symbol
	// then target range is the range enclosing this symbol not including
	// leading/trailing whitespace but everything else like comments. This
	// information is typically used to highlight the range in the editor.
	target_range Range @[json: 'targetRange']
	// The range that should be selected and revealed when this link is being
	// followed, e.g the name of a function. Must be contained by the
	// `targetRange`. See also `DocumentSymbol#range`
	target_selection_range Range @[json: 'targetSelectionRange']
}

// pub struct TextDocumentContentChangeEvent {
// range Range
// text string
// }
pub struct TextDocumentPositionParams {
pub:
	text_document TextDocumentIdentifier @[json: textDocument]
	position      Position
}

pub const markup_kind_plaintext = 'plaintext'

pub const markup_kind_markdown = 'markdown'

pub struct MarkupContent {
pub:
	kind string
	// MarkupKind
	value string
}

pub struct TextDocument {
	uri         DocumentUri
	language_id string
	version     int
	line_count  int
}

pub struct FullTextDocument {
	uri          DocumentUri
	language_id  string
	version      int
	content      string
	line_offsets []int
}
