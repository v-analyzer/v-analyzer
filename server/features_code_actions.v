module server

import lsp

pub fn (mut ls LanguageServer) code_actions(params lsp.CodeActionParams) ?[]lsp.CodeAction {
	// uri := params.text_document.uri.normalize()
	// file := ls.get_file(uri) or { return none }

	// mut actions := []lsp.CodeAction{}

	// for node in psi.new_psi_tree_walker(file.psi_file.root()) {
	// 	if node is psi.StructDeclaration {
	// 		actions << lsp.CodeAction{
	// 			title: "Implement interface",
	// 			kind: lsp.refactor,
	// 		}
	// 	}
	// }

	return []
}
