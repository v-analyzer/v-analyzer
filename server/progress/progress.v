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
module progress

import lsp
import server.protocol

pub struct Tracker {
pub mut:
	support_work_done_progress bool
	client                     &protocol.Client = unsafe { nil }
}

pub fn new_tracker(mut client protocol.Client) &Tracker {
	return &Tracker{
		client: client
	}
}

pub fn (mut t Tracker) start(title string, message string, token lsp.ProgressToken) &WorkDone {
	mut wd := &WorkDone{
		token: token
		client: t.client
	}

	if !t.support_work_done_progress {
		t.client.show_message(message, .log)
		return wd
	}

	if wd.token.empty() {
		new_token := lsp.generate_progress_token()
		t.client.work_done_progress_create(token: new_token)
		wd.token = new_token
	}

	t.client.progress(
		token: wd.token
		value: lsp.WorkDoneProgressPayload{
			kind: 'begin'
			title: title
			message: message
			percentage: 0
			cancellable: false
		}
	)

	return wd
}

@[heap]
pub struct WorkDone {
pub mut:
	token  lsp.ProgressToken
	client &protocol.Client
}

pub fn (mut wd WorkDone) progress(message string, percentage u32) {
	if wd.token.empty() {
		return
	}

	wd.client.progress(
		token: wd.token
		value: lsp.WorkDoneProgressPayload{
			kind: 'report'
			message: message.trim_string_right('\n')
			percentage: percentage
		}
	)
}

pub fn (mut wd WorkDone) end(message string) {
	if wd.token.empty() {
		wd.client.show_message(message, .info)
		return
	}

	wd.client.progress(
		token: wd.token
		value: lsp.WorkDoneProgressPayload{
			kind: 'end'
			message: message
		}
	)
}
