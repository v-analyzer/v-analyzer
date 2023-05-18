module lserver

import lsp
import runtime
import os

// initialize sends the server capabilities to the client
pub fn (mut ls LanguageServer) initialize(params lsp.InitializeParams, mut wr ResponseWriter) lsp.InitializeResult {
	ls.client_pid = params.process_id

	ls.root_uri = params.root_uri
	ls.status = .initialized

	ls.print_info(params.process_id, params.client_info, mut wr)

	ls.analyzer_instance.indexer.add_indexing_root('file:///Users/petrmakhnev/v/vlib')
	ls.analyzer_instance.indexer.add_indexing_root('file:///Users/petrmakhnev/intellij-v/src/main/resources/stubs/')
	ls.analyzer_instance.indexer.add_indexing_root(ls.root_uri)

	status := ls.analyzer_instance.indexer.index()
	if status == .needs_ensure_indexed {
		ls.analyzer_instance.indexer.ensure_indexed()
	}

	ls.analyzer_instance.indexer.save_indexes() or {
		wr.log_message('Failed to save index: ${err}', .error)
	}

	ls.analyzer_instance.setup_stub_indexes()

	wr.show_message('Hello, World!', .info)

	return lsp.InitializeResult{
		capabilities: lsp.ServerCapabilities{
			text_document_sync: .full
			hover_provider: true
			definition_provider: true
			references_provider: true
			completion_provider: lsp.CompletionOptions{
				resolve_provider: false
				trigger_characters: ['=', '.', ':', '{', ',', '(', ' ']
			}
			signature_help_provider: lsp.SignatureHelpOptions{
				trigger_characters: ['(', ',']
				retrigger_characters: [',', ' ']
			}
			code_lens_provider: lsp.CodeLensOptions{}
			inlay_hint_provider: lsp.InlayHintOptions{}
			semantic_tokens_provider: lsp.SemanticTokensOptions{
				legend: lsp.SemanticTokensLegend{
					token_types: semantic_types
					token_modifiers: semantic_modifiers
				}
				range: false
				full: true
			}
			rename_provider: lsp.RenameOptions{
				prepare_provider: false
			}
		}
		server_info: lsp.ServerInfo{
			name: 'spavn-analyzer'
			version: '0.0.1-alpha'
		}
	}
}

// shutdown sets the state to shutdown but does not exit
[noreturn]
pub fn (mut ls LanguageServer) shutdown(mut wr ResponseWriter) {
	ls.status = .shutdown
	ls.exit(mut wr)
}

// exit stops the process
[noreturn]
pub fn (mut ls LanguageServer) exit(mut rw ResponseWriter) {
	// saves the log into the disk
	// rw.server.dispatch_event(log.close_event, '') or {}
	// ls.typing_ch.close()

	// move exit to shutdown for now
	// == .shutdown => 0
	// != .shutdown => 1
	exit(int(ls.status != .shutdown))
}

fn (mut _ LanguageServer) print_info(process_id int, client_info lsp.ClientInfo, mut wr ResponseWriter) {
	arch := if runtime.is_64bit() { 64 } else { 32 }
	client_name := if client_info.name.len != 0 {
		'${client_info.name} ${client_info.version}'
	} else {
		'Unknown'
	}

	wr.log_message('VLS Version: 0.0.1, OS: ${os.user_os()} ${arch}', .info)
	wr.log_message('VLS executable path: ${os.executable()}', .info)
	wr.log_message('VLS build with V ${@VHASH}', .info)
	wr.log_message('Client / Editor: ${client_name} (PID: ${process_id})', .info)
}
