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
module log

import json

struct TestLogItem {
	kind    string
	payload string
}

fn test_notification_send() {
	mut lg := new()

	lg.log(kind: .send_notification, payload: '"Hello!"'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'send-notification'
	assert result.payload == 'Hello!'
}

fn test_notification_receive() {
	mut lg := new()

	lg.log(kind: .recv_notification, payload: '"Received!"'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'recv-notification'
	assert result.payload == 'Received!'
}

fn test_request_send() {
	mut lg := new()

	lg.log(kind: .recv_request, payload: '"Request sent."'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'recv-request'
	assert result.payload == 'Request sent.'
}

fn test_request_receive() {
	mut lg := new()

	lg.log(kind: .recv_request, payload: '"Request received."'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'recv-request'
	assert result.payload == 'Request received.'
}

fn test_response_send() {
	mut lg := new()

	lg.log(kind: .send_response, payload: '"Response sent."'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'send-response'
	assert result.payload == 'Response sent.'
}

fn test_response_receive() {
	mut lg := new()

	lg.log(kind: .send_response, payload: '"Response received."'.bytes())
	buf := lg.buffer.str()
	result := json.decode(TestLogItem, buf)!

	assert result.kind == 'send-response'
	assert result.payload == 'Response received.'
}
