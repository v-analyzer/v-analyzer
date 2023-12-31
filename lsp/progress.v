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

import rand
import crypto.md5

pub type ProgressToken = string

pub fn (t ProgressToken) empty() bool {
	return t == ''
}

pub fn generate_progress_token() ProgressToken {
	value := rand.intn(1000000) or { 0 }
	return md5.hexhash(value.str())
}

pub struct WorkDoneProgressParams {
pub:
	work_done_token ProgressToken @[json: 'workDoneToken'; omitempty]
}

pub struct PartialResultParams {
pub:
	partial_result_token ProgressToken @[json: 'partialResultToken'; omitempty]
}

pub struct WorkDoneProgressCreateParams {
pub:
	token ProgressToken
}

pub struct ProgressParams {
pub:
	token ProgressToken
	value WorkDoneProgressPayload
}

pub struct WorkDoneProgressPayload {
pub:
	// begin / report / end
	kind string
	// Mandatory title of the progress operation. Used to briefly inform about
	// the kind of operation being performed.
	//
	// Examples: "Indexing" or "Linking dependencies".
	title string @[omitempty]
	// Controls if a cancel button should show to allow the user to cancel the
	// long running operation. Clients that don't support cancellation are
	// allowed to ignore the setting.
	cancellable bool @[omitempty]
	// Optional, more detailed associated progress message. Contains
	// complementary information to the `title`.
	//
	// Examples: "3/25 files", "project/src/module2", "node_modules/some_dep".
	// If unset, the previous progress message (if any) is still valid.
	message string @[omitempty]
	// Optional progress percentage to display (value 100 is considered 100%).
	// If not provided infinite progress is assumed and clients are allowed
	// to ignore the `percentage` value in subsequent in report notifications.
	//
	// The value should be steadily rising. Clients are free to ignore values
	// that are not following this rule. The value range is [0, 100]
	percentage u32
}

pub struct WorkDoneProgressBegin {
	WorkDoneProgressPayload
pub:
	kind string = 'begin'
}

pub struct WorkDoneProgressReport {
	WorkDoneProgressPayload
pub:
	kind string = 'report'
}

pub struct WorkDoneProgressEnd {
	WorkDoneProgressPayload
	kind string = 'end'
}
