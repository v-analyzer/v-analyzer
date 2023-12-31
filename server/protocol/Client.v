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
module protocol

import jsonrpc
import lsp

@[heap]
pub struct Client {
mut:
	wr jsonrpc.ResponseWriter
}

pub fn new_client(mut wr jsonrpc.ResponseWriter) &Client {
	return &Client{
		wr: wr
	}
}

pub fn (mut c Client) work_done_progress_create(params lsp.WorkDoneProgressCreateParams) {
	c.wr.write_request('window/workDoneProgress/create', params)
}

pub fn (mut c Client) progress(params lsp.ProgressParams) {
	c.wr.write_notify('$/progress', params)
}

// log_message sends a window/logMessage notification to the client
pub fn (mut c Client) log_message(message string, typ lsp.MessageType) {
	c.wr.write_notify('window/logMessage', lsp.LogMessageParams{
		@type: typ
		message: message
	})
}

// show_message sends a window/showMessage notification to the client
pub fn (mut c Client) show_message(message string, typ lsp.MessageType) {
	c.wr.write_notify('window/showMessage', lsp.ShowMessageParams{
		@type: typ
		message: message
	})
}

pub fn (mut c Client) show_message_request(message string, actions []lsp.MessageActionItem, typ lsp.MessageType) {
	c.wr.write_notify('window/showMessageRequest', lsp.ShowMessageRequestParams{
		@type: typ
		message: message
		actions: actions
	})
}

pub fn (mut c Client) send_server_status(params lsp.ServerStatusParams) {
	c.wr.write_notify('experimental/serverStatus', params)
}

pub fn (mut c Client) apply_edit(params lsp.ApplyWorkspaceEditParams) {
	c.wr.write_request('workspace/applyEdit', params)
}
