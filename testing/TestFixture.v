module testing

import os
import testing.client
import lsp
import jsonrpc
import lserver
import analyzer

const temp_path = os.join_path(os.temp_dir(), 'spavn-analyzer-test')

struct TestFile {
	path    string
	content []string
	caret   lsp.Position
}

pub fn (t TestFile) uri() lsp.DocumentUri {
	return 'file://${t.path}'
}

[noinit]
pub struct Fixture {
mut:
	ls           &lserver.LanguageServer
	stream       &client.TestStream
	server       &jsonrpc.Server
	test_client  client.TestClient
	current_file TestFile

	opened_files []string
}

pub fn new_fixture() &Fixture {
	analyzer_instance := analyzer.new()
	mut ls := lserver.new(analyzer_instance)

	stream := &client.TestStream{}
	mut server := &jsonrpc.Server{
		stream: stream
		handler: ls
	}

	mut test_client := client.TestClient{
		server: server
		stream: stream
	}

	return &Fixture{
		ls: ls
		stream: stream
		server: server
		test_client: test_client
	}
}

pub fn (mut t Fixture) initialize() !lsp.InitializeResult {
	os.mkdir_all(testing.temp_path)!

	result := t.test_client.send[lsp.InitializeParams, lsp.InitializeResult]('initialize',
		lsp.InitializeParams{
		process_id: 75556
		client_info: lsp.ClientInfo{
			name: 'Testing'
			version: '0.0.1'
		}
		root_uri: 'file://${testing.temp_path}'
		root_path: testing.temp_path
		initialization_options: 'no-stdlib'
		capabilities: lsp.ClientCapabilities{}
		trace: ''
		workspace_folders: []
	})!

	return result
}

pub fn (mut t Fixture) configure_by_file(path string) ! {
	rel_path := 'testdata/${path}'
	content := os.read_file(rel_path)!
	abs_path := os.join_path(testing.temp_path, path)
	dir_path := os.dir(abs_path)
	os.mkdir_all(dir_path)!
	os.write_file(abs_path, content)!

	if t.current_file.path == abs_path {
		t.close_file(t.current_file.path)
	}

	t.current_file = TestFile{
		path: abs_path
		content: content.split_into_lines()
		caret: t.caret_pos(content)
	}

	t.send_open_current_file_request()!
}

pub fn (mut t Fixture) configure_by_text(filename string, text string) ! {
	content := text.replace('/*caret*/', '')
	abs_path := os.join_path(testing.temp_path, filename)
	os.write_file(abs_path, content)!

	if t.current_file.path == abs_path {
		t.close_file(t.current_file.path)
	}

	t.current_file = TestFile{
		path: abs_path
		content: content.split_into_lines()
		caret: t.caret_pos(text)
	}

	t.send_open_current_file_request()!
}

fn (mut t Fixture) send_open_current_file_request() ! {
	t.test_client.send[lsp.DidOpenTextDocumentParams, jsonrpc.Null]('textDocument/didOpen',
		lsp.DidOpenTextDocumentParams{
		text_document: lsp.TextDocumentItem{
			uri: 'file://${t.current_file.path}'
			language_id: 'v'
			version: 1
			text: t.current_file.content.join('\n')
		}
	})!
}

pub fn (mut t Fixture) definition_at_cursor() []lsp.LocationLink {
	return t.definition(t.current_caret_pos())
}

pub fn (mut t Fixture) definition(pos lsp.Position) []lsp.LocationLink {
	links := t.test_client.send[lsp.TextDocumentPositionParams, []lsp.LocationLink]('textDocument/definition',
		lsp.TextDocumentPositionParams{
		text_document: lsp.TextDocumentIdentifier{
			uri: 'file://${t.current_file.path}'
		}
		position: pos
	}) or { []lsp.LocationLink{} }

	return links
}

pub fn (mut t Fixture) complete_at_cursor() []lsp.CompletionItem {
	return t.complete(t.current_caret_pos())
}

pub fn (mut t Fixture) complete(pos lsp.Position) []lsp.CompletionItem {
	items := t.test_client.send[lsp.CompletionParams, []lsp.CompletionItem]('textDocument/completion',
		lsp.CompletionParams{
		text_document: lsp.TextDocumentIdentifier{
			uri: 'file://${t.current_file.path}'
		}
		position: pos
		context: lsp.CompletionContext{
			trigger_kind: .invoked
		}
	}) or { []lsp.CompletionItem{} }

	return items
}

pub fn (mut t Fixture) compute_inlay_hints() []lsp.InlayHint {
	hints := t.test_client.send[lsp.InlayHintParams, []lsp.InlayHint]('textDocument/inlayHint',
		lsp.InlayHintParams{
		text_document: lsp.TextDocumentIdentifier{
			uri: 'file://${t.current_file.path}'
		}
	}) or { []lsp.InlayHint{} }

	return hints
}

pub fn (mut t Fixture) compute_semantic_tokens() lsp.SemanticTokens {
	tokens := t.test_client.send[lsp.SemanticTokensParams, lsp.SemanticTokens]('textDocument/semanticTokens/full',
		lsp.SemanticTokensParams{
		text_document: lsp.TextDocumentIdentifier{
			uri: 'file://${t.current_file.path}'
		}
	}) or { lsp.SemanticTokens{} }

	return tokens
}

pub fn (mut t Fixture) close_file(path string) {
	t.test_client.send[lsp.DidCloseTextDocumentParams, jsonrpc.Null]('textDocument/didClose',
		lsp.DidCloseTextDocumentParams{
		text_document: lsp.TextDocumentIdentifier{
			uri: 'file://${path}'
		}
	}) or { println('Failed to close document: ${err}') }
}

pub fn (mut t Fixture) current_file_uri() lsp.DocumentUri {
	return 'file://${t.current_file.path}'
}

pub fn (mut t Fixture) text_at_range(range lsp.Range) string {
	lines := t.current_file.content
	start := range.start
	end := range.end

	if start.line == end.line {
		return lines[start.line][start.character..end.character]
	}

	mut result := lines[start.line][start.character..]

	for line in lines[start.line + 1..end.line] {
		result += line
	}

	result += lines[end.line][..end.character]

	return result
}

pub fn (mut t Fixture) current_caret_pos() lsp.Position {
	return t.current_file.caret
}

pub fn (mut t Fixture) caret_pos(file string) lsp.Position {
	for index, line in file.split_into_lines() {
		if line.contains('/*caret*/') {
			return lsp.Position{
				line: index
				character: line.index('/*caret*/') or { 0 }
			}
		}
	}

	return lsp.Position{
		line: 0
		character: 0
	}
}
