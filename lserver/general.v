module lserver

import lsp
import runtime
import os
import project
import metadata
import time
import config
import lserver.semantic

// initialize sends the server capabilities to the client
pub fn (mut ls LanguageServer) initialize(params lsp.InitializeParams, mut wr ResponseWriter) lsp.InitializeResult {
	ls.client_pid = params.process_id

	ls.root_uri = params.root_uri
	ls.status = .initialized

	ls.print_info(params.process_id, params.client_info, mut wr)
	ls.setup(mut wr)

	// Used in tests to avoid indexing the standard library
	need_index_stdlib := 'no-stdlib' !in params.initialization_options.fields()

	if need_index_stdlib {
		if vlib_root := ls.vlib_root() {
			ls.analyzer_instance.indexer.add_indexing_root(vlib_root, .standard_library)
		}
		if vmodules_root := ls.vmodules_root() {
			ls.analyzer_instance.indexer.add_indexing_root(vmodules_root, .modules)
		}
		if stubs_root := ls.stubs_root() {
			ls.analyzer_instance.indexer.add_indexing_root(stubs_root, .stubs)
		}
	}

	ls.analyzer_instance.indexer.add_indexing_root(ls.root_uri.path(), .workspace)

	status := ls.analyzer_instance.indexer.index()
	if status == .needs_ensure_indexed {
		ls.analyzer_instance.indexer.ensure_indexed()
	}

	// Used in tests to avoid indexing the standard library
	need_save_index := 'no-index-save' !in params.initialization_options.fields()

	if need_save_index {
		ls.analyzer_instance.indexer.save_indexes() or {
			wr.log_message('Failed to save index: ${err}', .error)
		}
	}

	ls.analyzer_instance.setup_stub_indexes()

	wr.show_message('Hello, World!', .info)

	return lsp.InitializeResult{
		capabilities: lsp.ServerCapabilities{
			text_document_sync: lsp.TextDocumentSyncOptions{
				open_close: true
				change: .full
			}
			hover_provider: true
			definition_provider: true
			type_definition_provider: true
			references_provider: true
			document_formatting_provider: true
			completion_provider: lsp.CompletionOptions{
				resolve_provider: false
				trigger_characters: ['.', ':', ',', '(']
			}
			signature_help_provider: lsp.SignatureHelpOptions{
				trigger_characters: ['(', ',']
				retrigger_characters: [',', ' ']
			}
			code_lens_provider: lsp.CodeLensOptions{}
			inlay_hint_provider: lsp.InlayHintOptions{}
			semantic_tokens_provider: lsp.SemanticTokensOptions{
				legend: lsp.SemanticTokensLegend{
					token_types: semantic.semantic_types
					token_modifiers: semantic.semantic_modifiers
				}
				range: false
				full: true
			}
			rename_provider: lsp.RenameOptions{
				prepare_provider: false
			}
			document_symbol_provider: true
		}
		server_info: lsp.ServerInfo{
			name: 'spavn-analyzer'
			version: '0.0.1-alpha'
		}
	}
}

fn (mut ls LanguageServer) setup(mut rw ResponseWriter) {
	ls.setup_config_dir(mut rw)
	ls.setup_stubs(mut rw)

	config_path := ls.find_config()
	if config_path == '' {
		rw.log_message('No config found', .warning)
		ls.setup_toolchain(mut rw)
		ls.setup_vmodules(mut rw)
		return
	}

	config_content := os.read_file(config_path) or {
		rw.log_message('Failed to read config: ${err}', .error)
		return
	}

	cfg := config.from_toml(ls.root_uri.path(), config_path, config_content) or {
		rw.log_message('Failed to decode config: ${err}', .error)
		rw.log_message('Using default config', .info)
		config.EditorConfig{}
	}

	config_type := if cfg.is_local() { 'local' } else { 'global' }
	rw.log_message('Using ${config_type} config: ${config_path}', .info)

	ls.cfg = cfg
	if cfg.custom_vroot != '' {
		ls.vroot = os.expand_tilde_to_home(cfg.custom_vroot)

		rw.log_message("Find custom VROOT path in '${cfg.path()}' config", .info)
		rw.log_message('Using "${cfg.custom_vroot}" as toolchain', .info)
	}

	if ls.vroot == '' {
		// if custom vroot is not set, try to find it
		ls.setup_toolchain(mut rw)
	}

	ls.setup_vmodules(mut rw)
}

fn (mut ls LanguageServer) find_config() string {
	root := ls.root_uri.path()
	local_config_path := os.join_path(root, '.spavn-analyzer', 'config.toml')
	if os.exists(local_config_path) {
		return local_config_path
	}

	global_config_path := os.join_path(config.analyzer_configs_path, 'config.toml')
	if os.exists(global_config_path) {
		return global_config_path
	}

	return ''
}

fn (mut ls LanguageServer) setup_toolchain(mut rw ResponseWriter) {
	toolchain_candidates := project.get_toolchain_candidates()
	if toolchain_candidates.len > 0 {
		rw.log_message('Found toolchain candidates:', .info)
		for toolchain_candidate in toolchain_candidates {
			rw.log_message('  ${toolchain_candidate}', .info)
		}

		rw.log_message('Using "${toolchain_candidates.first()}" as toolchain', .info)
		ls.vroot = toolchain_candidates.first()
	} else {
		rw.log_message("No toolchain candidates found, some of the features won't work properly.
Please, set `custom_vroot` in local or global config.",
			.error)
	}
}

fn (mut ls LanguageServer) setup_vmodules(mut rw ResponseWriter) {
	ls.vmodules_root = project.get_modules_location()
	rw.log_message('Using "${ls.vmodules_root}" as vmodules root', .info)
}

fn (mut _ LanguageServer) setup_config_dir(mut rw ResponseWriter) {
	if !os.exists(config.analyzer_configs_path) {
		os.mkdir(config.analyzer_configs_path) or {
			rw.log_message('Failed to create analyzer configs directory: ${err}', .error)
			return
		}
	}

	if !os.exists(config.analyzer_global_config_path) {
		rw.log_message('Global config not found', .info)
		rw.log_message('Creating default global analyzer config', .info)

		os.write_file(config.analyzer_global_config_path, config.default) or {
			rw.log_message('Failed to create global default analyzer config: ${err}',
				.error)
			return
		}

		rw.log_message('Default analyzer config created at ${config.analyzer_global_config_path}',
			.info)
	}
}

fn (mut _ LanguageServer) setup_stubs(mut rw ResponseWriter) {
	if os.exists(config.analyzer_stubs_path) {
		// TODO: check if the stubs are up to date
		return
	}

	stubs := metadata.embed_fs()
	stubs.unpack_to(config.analyzer_stubs_path) or {
		rw.log_message('Failed to unpack stubs: ${err}', .error)
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

	wr.log_message('spavn-analyzer version: 0.0.1, OS: ${os.user_os()} x${arch}', .info)
	wr.log_message('spavn-analyzer executable path: ${os.executable()}', .info)
	wr.log_message('spavn-analyzer build with V ${@VHASH}', .info)
	wr.log_message('spavn-analyzer build at ${time.now().format_ss()}', .info)
	wr.log_message('Client / Editor: ${client_name} (PID: ${process_id})', .info)
}
