module server

import lsp
import loglib
import json
import server.intentions

pub struct IntentionData {
pub:
	file_uri string
	position lsp.Position
}

pub fn (mut ls LanguageServer) execute_command(params lsp.ExecuteCommandParams) ? {
	if mut intention := ls.intentions[params.command] {
		arguments := json.decode([]string, params.arguments) or { []string{} }

		argument := json.decode(IntentionData, arguments[0]) or {
			loglib.with_fields({
				'command':  params.command
				'argument': params.arguments
			}).warn('Got invalid argument')
			return
		}

		file_uri := argument.file_uri
		file := ls.get_file(file_uri)?
		pos := argument.position

		ctx := intentions.IntentionContext.from(file.psi_file, pos)
		edits := intention.invoke(ctx) or { return }

		ls.client.apply_edit(edit: edits)
	}
}
