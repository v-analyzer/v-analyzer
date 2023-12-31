// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module lsp

// method: ‘initialize’
// response: InitializeResult
pub struct InitializeParams {
pub mut:
	process_id             int = -2                @[json: processId]
	client_info            ClientInfo         @[json: clientInfo]
	root_uri               DocumentUri        @[json: rootUri]
	root_path              DocumentUri        @[json: rootPath]
	initialization_options string             @[json: initializationOptions]
	capabilities           ClientCapabilities
	trace                  string
	workspace_folders      []WorkspaceFolder  @[skip]
}

pub struct ClientInfo {
pub mut:
	name    string @[json: name]
	version string @[json: version]
}

pub struct ServerInfo {
pub mut:
	name    string
	version string
}

pub struct InitializeResult {
pub:
	capabilities ServerCapabilities
	server_info  ServerInfo         @[json: 'serverInfo'; omitempty]
}

// method: ‘initialized’
// notification
// pub struct InitializedParams {}

@[json_as_number]
pub enum InitializeErrorCode {
	unknown_protocol_version = 1
}

pub struct InitializeError {
	retry bool
}

/*
*
 * The kind of resource operations supported by the client.
*/

@[json_as_number]
pub enum ResourceOperationKind {
	create
	rename
	delete
}

@[json_as_number]
pub enum FailureHandlingKind {
	abort
	transactional
	undo
	text_only_transactional
}

pub struct ExecuteCommandOptions {
pub:
	// The commands to be executed on the server
	commands []string
}

pub struct StaticRegistrationOptions {
	id string
}

// method: ‘shutdown’
// response: none
// method: ‘exit’
// response: none
