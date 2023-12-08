module server

import lsp
import server.hints

pub fn (mut ls LanguageServer) inlay_hints(params lsp.InlayHintParams) []lsp.InlayHint {
	empty_hint := []lsp.InlayHint{}
	if !ls.cfg.inlay_hints.enable {
		return empty_hint
	}

	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return empty_hint }

	mut visitor := hints.InlayHintsVisitor{
		cfg: ls.cfg.inlay_hints
	}
	visitor.accept(file.psi_file.root())
	return visitor.result
}
