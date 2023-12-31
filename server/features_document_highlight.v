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
module server

import lsp
import loglib
import server.tform
import analyzer.psi
import analyzer.psi.search

pub fn (mut ls LanguageServer) document_highlight(params lsp.TextDocumentPositionParams) ?[]lsp.DocumentHighlight {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		loglib.with_fields({
			'caller': @METHOD
			'offset': offset.str()
		}).warn('Cannot find element')
		return []
	}

	references := search.references(element, include_declaration: true, only_in_current_file: true)

	mut highlights := []lsp.DocumentHighlight{}
	for reference in references {
		range := if reference is psi.PsiNamedElement {
			reference.identifier_text_range()
		} else {
			reference.text_range()
		}
		highlights << lsp.DocumentHighlight{
			range: tform.text_range_to_lsp_range(range)
			kind: read_write_kind(reference)
		}
	}

	return highlights
}

// read_write_kind returns the kind of the highlight for the given element.
//
// - `DocumentHighlightKind.read` means that the highlight is a read access,
// - `DocumentHighlightKind.write` means that the highlight is a write access.
// - `DocumentHighlightKind.text` means that the highlight is neither a read nor a write access.
fn read_write_kind(element psi.PsiElement) lsp.DocumentHighlightKind {
	parent := element.parent() or { return .text }

	if element is psi.VarDefinition || element is psi.ConstantDefinition
		|| element is psi.ParameterDeclaration || element is psi.Receiver
		|| element is psi.FieldDeclaration || element is psi.EnumFieldDeclaration {
		// for parameter/receiver not an actual write, but we want to highlight it
		// with different color than read access.
		return .write
	}

	if parent.element_type() == .expression_list {
		grand := parent.parent() or { return .text }
		if grand.element_type() == .assignment_statement {
			left := grand.first_child() or { return .text }
			if left.is_parent_of(element) {
				return .write
			}
			return .read
		}
	}

	if parent.element_type() in [.send_statement, .append_statement] {
		left := parent.first_child() or { return .text }
		if left.is_parent_of(element) {
			return .write
		}
		return .read
	}

	if parent.element_type() in [.send_statement, .append_statement, .field_name] {
		return .write
	}

	return .read
}
