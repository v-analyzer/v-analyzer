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
module file_diff

import lsp

pub struct Edit {
	range    lsp.Range
	new_text string
}

pub struct Diff {
	uri lsp.DocumentUri
mut:
	edits []Edit
}

pub fn Diff.for_file(uri lsp.DocumentUri) Diff {
	return Diff{
		uri: uri
	}
}

pub fn (mut diff Diff) append_to_begin(line int, text string) {
	diff.append_to(line, 0, text)
}

pub fn (mut diff Diff) append_to(line int, col int, text string) {
	pos := Diff.line_pos(line, col)
	diff.edits << Edit{
		range: lsp.Range{
			start: pos
			end: pos
		}
		new_text: text
	}
}

pub fn (mut diff Diff) append_as_prev_line(line int, text string) {
	pos := Diff.line_begin_pos(line)
	diff.edits << Edit{
		range: lsp.Range{
			start: pos
			end: pos
		}
		new_text: '${text}\n'
	}
}

pub fn (mut diff Diff) append_as_next_line(line int, text string) {
	pos := Diff.line_begin_pos(line)
	diff.edits << Edit{
		range: lsp.Range{
			start: pos
			end: pos
		}
		new_text: '\n${text}'
	}
}

pub fn (mut diff Diff) to_workspace_edit() lsp.WorkspaceEdit {
	return lsp.WorkspaceEdit{
		changes: {
			diff.uri: diff.edits.map(lsp.TextEdit{
				range: it.range
				new_text: it.new_text
			})
		}
	}
}

fn Diff.line_begin_pos(line int) lsp.Position {
	return lsp.Position{
		line: line
		character: 0
	}
}

fn Diff.line_pos(line int, col int) lsp.Position {
	return lsp.Position{
		line: line
		character: col
	}
}
