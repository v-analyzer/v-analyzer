module server

import json
import jsonrpc
import lsp
import time
import analyzer
import os
import config
import loglib
import server.progress
import server.protocol

pub enum ServerStatus {
	off
	initialized
	shutdown
}

pub struct LanguageServer {
pub mut:
	status       ServerStatus = .off
	root_uri     lsp.DocumentUri
	capabilities lsp.ServerCapabilities

	client &protocol.Client
	// client_pid is the process ID of this server.
	client_pid int
	writer     &ResponseWriter = &ResponseWriter(unsafe { nil })
	// opened_files describes all open files in the editor.
	//
	// When a file is opened, the `did_open` method is called,
	// which adds the file to `opened_files`.
	//
	// When the file is closed, the `did_close` method is called,
	// which removes the file from `opened_files`.
	opened_files map[lsp.DocumentUri]analyzer.OpenedFile

	vmodules_root string
	vroot         string
	cache_dir     string

	initialization_options []string

	cfg config.EditorConfig

	progress          &progress.Tracker
	analyzer_instance analyzer.Analyzer
}

pub fn new(analyzer_instance analyzer.Analyzer) &LanguageServer {
	return &LanguageServer{
		analyzer_instance: analyzer_instance
		client: unsafe { nil } // will be initialized in `initialize`
		progress: unsafe { nil } // will be initialized in `initialize`
	}
}

pub fn (mut ls LanguageServer) compiler_path() ?string {
	if ls.vroot == '' {
		return none
	}
	compiler_exe_name := $if windows { 'v.exe' } $else { 'v' }
	return os.join_path(ls.vroot, compiler_exe_name)
}

pub fn (mut ls LanguageServer) vlib_root() ?string {
	if ls.vroot == '' {
		return none
	}

	path := os.join_path(ls.vroot, 'vlib')
	if !os.is_dir(path) {
		return none
	}
	return path
}

pub fn (mut ls LanguageServer) vmodules_root() ?string {
	if !os.is_dir(ls.vmodules_root) {
		return none
	}
	return ls.vmodules_root
}

pub fn (mut _ LanguageServer) stubs_root() ?string {
	if !os.exists(config.analyzer_stubs_path) {
		return none
	}
	return config.analyzer_stubs_path
}

pub fn (mut ls LanguageServer) get_file(uri lsp.DocumentUri) ?analyzer.OpenedFile {
	return ls.opened_files[uri] or {
		loglib.with_fields({
			'uri': uri.str()
		}).warn('Cannot find file in opened_files')
		return none
	}
}

pub fn (mut ls LanguageServer) handle_jsonrpc(request &jsonrpc.Request, mut rw jsonrpc.ResponseWriter) ! {
	// initialize writer upon receiving the first request
	if isnil(ls.writer) {
		ls.writer = rw.server.writer(own_buffer: true)
	}

	watch := time.new_stopwatch(auto_start: true)

	mut w := unsafe { &ResponseWriter(rw) }

	// The server will log a send request/notification
	// log based on the the received payload since the spec
	// doesn't indicate a way to log on the client side and
	// notify it to the server.
	//
	// Notification has no ID attached so the server can detect
	// if its a notification or a request payload by checking
	// if the ID is empty.
	if request.method == 'shutdown' {
		// Note: LSP specification is unclear whether or not
		// a shutdown request is allowed before server init
		// but we'll just put it here since we want to formally
		// shutdown the server after a certain timeout period.
		ls.shutdown()
	} else if ls.status == .initialized {
		match request.method {
			// not only requests but also notifications
			'initialized' {
				ls.initialized(mut rw)
			}
			'exit' {
				// ignore for the reasons stated in the above comment
				// ls.exit()
			}
			'textDocument/didOpen' {
				params := json.decode(lsp.DidOpenTextDocumentParams, request.params) or {
					return err
				}
				ls.did_open(params)
			}
			'textDocument/didSave' {
				params := json.decode(lsp.DidSaveTextDocumentParams, request.params) or {
					return err
				}
				ls.did_save(params)
			}
			'textDocument/didChange' {
				params := json.decode(lsp.DidChangeTextDocumentParams, request.params) or {
					return err
				}
				ls.did_change(params)
			}
			'textDocument/didClose' {
				params := json.decode(lsp.DidCloseTextDocumentParams, request.params) or {
					return err
				}
				ls.did_close(params)
			}
			'textDocument/willSave' {
				// params := json.decode(lsp.WillSaveTextDocumentParams, request.params) or {
				// 	return err
				// }
				// ls.will_save(params)
			}
			'textDocument/formatting' {
				params := json.decode(lsp.DocumentFormattingParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.formatting(params) or { return w.wrap_error(err) })
			}
			'textDocument/documentSymbol' {
				params := json.decode(lsp.DocumentSymbolParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.document_symbol(params) or { return w.wrap_error(err) })
			}
			'workspace/symbol' {
				params := json.decode(lsp.WorkspaceSymbolParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.workspace_symbol(params) or { return w.wrap_error(err) })
			}
			'textDocument/signatureHelp' {
				params := json.decode(lsp.SignatureHelpParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.signature_help(params) or { return w.wrap_error(err) })
			}
			'textDocument/completion' {
				params := json.decode(lsp.CompletionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.completion(params) or { return w.wrap_error(err) })
			}
			'textDocument/hover' {
				params := json.decode(lsp.HoverParams, request.params) or {
					return w.wrap_error(err)
				}
				hover_data := ls.hover(params) or {
					w.write_empty()
					return
				}
				w.write(hover_data)
			}
			'textDocument/foldingRange' {
				// params := json.decode(lsp.FoldingRangeParams, request.params) or {
				// 	return w.wrap_error(err)
				// }
				// w.write(ls.folding_range(params) or { return w.wrap_error(err) })
			}
			'textDocument/definition' {
				params := json.decode(lsp.TextDocumentPositionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.definition(params) or { return w.wrap_error(err) })
			}
			'textDocument/typeDefinition' {
				params := json.decode(lsp.TextDocumentPositionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.type_definition(params) or { return w.wrap_error(err) })
			}
			'textDocument/references' {
				params := json.decode(lsp.ReferenceParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.references(params))
			}
			'textDocument/implementation' {
				params := json.decode(lsp.TextDocumentPositionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.implementation(params) or { return w.wrap_error(err) })
			}
			'workspace/didChangeWatchedFiles' {
				params := json.decode(lsp.DidChangeWatchedFilesParams, request.params) or {
					return err
				}
				ls.did_change_watched_files(params)
			}
			'textDocument/codeLens' {
				params := json.decode(lsp.CodeLensParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.code_lens(params) or { return w.wrap_error(err) })
			}
			'textDocument/inlayHint' {
				params := json.decode(lsp.InlayHintParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.inlay_hints(params) or { return w.wrap_error(err) })
			}
			'textDocument/prepareRename' {
				params := json.decode(lsp.PrepareRenameParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.prepare_rename(params) or { return w.wrap_error(err) })
			}
			'textDocument/rename' {
				params := json.decode(lsp.RenameParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.rename(params) or { return w.wrap_error(err) })
			}
			'textDocument/documentLink' {}
			'textDocument/semanticTokens/full' {
				params := json.decode(lsp.SemanticTokensParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.semantic_tokens(params.text_document, lsp.Range{}) or {
					return w.wrap_error(err)
				})
			}
			'textDocument/semanticTokens/range' {
				params := json.decode(lsp.SemanticTokensRangeParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.semantic_tokens(params.text_document, params.range) or {
					return w.wrap_error(err)
				})
			}
			'textDocument/documentHighlight' {
				params := json.decode(lsp.TextDocumentPositionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.document_highlight(params) or { return w.wrap_error(err) })
			}
			'textDocument/codeAction' {
				params := json.decode(lsp.CodeActionParams, request.params) or {
					return w.wrap_error(err)
				}
				w.write(ls.code_actions(params) or { return w.wrap_error(err) })
			}
			'$/cancelRequest' {
				loglib.info('got $/cancelRequest request')
				return jsonrpc.response_error(error: jsonrpc.method_not_found, data: request.method).err()
			}
			else {
				loglib.with_fields({
					'method': request.method
					'params': request.params
				}).info('unhandled method call')
				return jsonrpc.response_error(error: jsonrpc.method_not_found, data: request.method).err()
			}
		}
	} else {
		match request.method {
			'exit' {
				ls.exit()
			}
			'initialize' {
				params := json.decode(lsp.InitializeParams, request.params) or { return err }
				w.write(ls.initialize(params, mut rw))
			}
			else {
				if ls.status == .shutdown {
					return jsonrpc.invalid_request
				} else {
					return jsonrpc.server_not_initialized
				}
			}
		}
	}

	loglib.with_fields({
		'method':   request.method
		'duration': watch.elapsed().str()
	}).log_one(.info, 'Request finished')
}

// launch_tool launches a tool with the same vroot as the language server
// and returns the process.
//
// Example:
// ```
// p := ls.launch_tool('tool', 'arg1', 'arg2')!
// defer {
//   p.close()
// }
// p.wait()
// ```
pub fn (mut ls LanguageServer) launch_tool(args ...string) !&os.Process {
	compiler_path := ls.compiler_path() or { return error('Cannot run tool without vroot') }
	mut p := os.new_process(compiler_path)
	p.set_args(args)
	p.set_redirect_stdio()
	return p
}
