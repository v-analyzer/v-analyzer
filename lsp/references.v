module lsp

// method: ‘textDocument/references’
// response: []Location | none
pub struct ReferenceParams {
pub:
	text_document TextDocumentIdentifier [json: textDocument]
	position      Position
	context       ReferenceContext
}

pub struct ReferenceContext {
	include_declaration bool
}
