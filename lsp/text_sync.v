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

pub struct TextDocumentSyncOptions {
pub:
	// Open and close notifications are sent to the server. If omitted open
	// close notifications should not be sent.
	open_close bool @[json: 'openClose']
	// Change notifications are sent to the server. See
	// TextDocumentSyncKind.None, TextDocumentSyncKind.Full and
	// TextDocumentSyncKind.Incremental. If omitted it defaults to
	// TextDocumentSyncKind.None.
	change TextDocumentSyncKind = TextDocumentSyncKind.full @[omitempty]
	// If present will save notifications are sent to the server. If omitted
	// the notification should not be sent.
	will_save bool @[json: 'willSave']
	// If present save notifications are sent to the server. If omitted the
	// notification should not be sent.
	save SaveOptions
}

pub struct SaveOptions {
	include_text bool @[json: 'includeText']
}

// method: ‘textDocument/didOpen’
// notification
pub struct DidOpenTextDocumentParams {
pub:
	text_document TextDocumentItem @[json: textDocument]
}

// method: ‘textDocument/didChange’
// notification
pub struct DidChangeTextDocumentParams {
pub:
	// The document that did change. The version number points
	// to the version after all provided content changes have
	// been applied.
	text_document VersionedTextDocumentIdentifier @[json: textDocument]
	// The actual content changes. The content changes describe single state
	// changes to the document. So if there are two content changes c1 (at
	// array index 0) and c2 (at array index 1) for a document in state S then
	// c1 moves the document from S to S' and c2 from S' to S''. So c1 is
	// computed on the state S and c2 is computed on the state S'.
	//
	// To mirror the content of a document using change events use the following
	// approach:
	// - start with the same initial content
	// - apply the 'textDocument/didChange' notifications in the order you
	//   receive them.
	// - apply the `TextDocumentContentChangeEvent`s in a single notification
	//   in the order you receive them.
	content_changes []TextDocumentContentChangeEvent @[json: contentChanges]
}

pub struct TextDocumentContentChangeEvent {
pub:
	// The range of the document that changed.
	range Range
	// The optional length of the range that got replaced.
	range_length int @[deprecated: 'use range instead'; json: 'rangeLength']
	// The new text for the provided range or the entire document.
	text string
}

pub struct TextDocumentChangeRegistrationOptions {
	document_selector []DocumentFilter @[json: documentSelector]
	sync_kind         int              @[json: syncKind]
}

// method: ‘textDocument/willSave’
// notification
pub struct WillSaveTextDocumentParams {
	text_document TextDocumentIdentifier @[json: textDocument]
	reason        TextDocumentSaveReason
}

@[json_as_number]
pub enum TextDocumentSaveReason {
	manual      = 1
	after_delay = 2
	focus_out   = 3
}

// ‘textDocument/willSaveWaitUntil’
// response: []TextEdit | null
// request: WillSaveTextDocumentParams
// method: ‘textDocument/didSave’
// notification
pub struct DidSaveTextDocumentParams {
pub:
	text_document TextDocumentIdentifier @[json: textDocument]
	text          string
}

// method: ‘textDocument/didClose’
// notification
pub struct DidCloseTextDocumentParams {
pub:
	text_document TextDocumentIdentifier @[json: textDocument]
}
