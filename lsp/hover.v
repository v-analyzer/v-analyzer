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

pub struct HoverSettings {
	dynamic_registration bool     @[json: dynamicRegistration]
	content_format       []string @[json: contentFormat]
}

// method: ‘textDocument/hover’
// response: Hover | none
// request: TextDocumentPositionParams
pub struct HoverParams {
pub:
	text_document TextDocumentIdentifier @[json: textDocument]
	position      Position
}

type HoverResponseContent = MarkedString | MarkupContent | []MarkedString | string

pub struct Hover {
pub:
	contents HoverResponseContent
	range    Range
}

// pub type MarkedString = string | MarkedString
pub struct MarkedString {
	language string
	value    string
}

pub fn hover_v_marked_string(text string) HoverResponseContent {
	return HoverResponseContent(MarkedString{
		language: 'v'
		value: text
	})
}

pub fn hover_markdown_string(text string) HoverResponseContent {
	return HoverResponseContent(MarkupContent{
		kind: markup_kind_markdown
		value: text
	})
}
