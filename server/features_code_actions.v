module server

import lsp
import json
import server.intentions

pub fn (mut ls LanguageServer) code_actions(params lsp.CodeActionParams) ?[]lsp.CodeAction {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	mut actions := []lsp.CodeAction{}

	ctx := intentions.IntentionContext.from(file.psi_file, params.range.start)

	for _, mut intention in ls.intentions {
		if !intention.is_available(ctx) {
			continue
		}

		actions << lsp.CodeAction{
			title: intention.name
			kind: lsp.refactor
			command: lsp.Command{
				title: intention.name
				command: intention.id
				arguments: [
					json.encode(IntentionData{
						file_uri: uri
						position: params.range.start
					}),
				]
			}
		}
	}

	return actions
}
