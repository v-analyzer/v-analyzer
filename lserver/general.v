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

	if os.exists('./index.json') {
		ls.analyzer_instance.load_index('./index.json')
	} else {
		ls.analyzer_instance.index('file:///Users/petrmakhnev/v/vlib')
	}

	ls.analyzer_instance.index(ls.root_uri)

	wr.show_message('Hello, World!', .info)

	return lsp.InitializeResult{
		capabilities: lsp.ServerCapabilities{
			text_document_sync: .incremental
			hover_provider: true
			definition_provider: true
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

fn (mut ls LanguageServer) print_info(process_id int, client_info lsp.ClientInfo, mut wr ResponseWriter) {
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
