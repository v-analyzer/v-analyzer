module lserver

import lsp
import lserver.hints

pub fn (mut ls LanguageServer) inlay_hints(params lsp.InlayHintParams, mut wr ResponseWriter) ?[]lsp.InlayHint {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	mut visitor := hints.InlayHintsVisitor{}
	visitor.accept(file.psi_file.root())
	return visitor.result
}
