module lserver

import lsp

pub fn (mut ls LanguageServer) inlay_hints(params lsp.InlayHintParams, mut wr ResponseWriter) ?[]lsp.InlayHint {
	return [
		lsp.InlayHint{
			position: lsp.Position{
				line: 6
				character: 1
			}
			label: 'hello'
			kind: .type_
		},
	]
}
