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
module tform

import lsp
import analyzer.psi

// elements_to_locations converts an array of PsiElements to a slice of LSP locations.
pub fn elements_to_locations(elements []psi.PsiElement) []lsp.Location {
	return elements.map(fn (element psi.PsiElement) lsp.Location {
		range := if element is psi.PsiNamedElement {
			element.identifier_text_range()
		} else {
			element.text_range()
		}
		return lsp.Location{
			uri: element.containing_file.uri()
			range: text_range_to_lsp_range(range)
		}
	})
}

// text_range_to_lsp_range converts a TextRange to an LSP Range.
pub fn text_range_to_lsp_range(pos psi.TextRange) lsp.Range {
	return lsp.Range{
		start: lsp.Position{
			line: pos.line
			character: pos.column
		}
		end: lsp.Position{
			line: pos.end_line
			character: pos.end_column
		}
	}
}

// elements_to_text_edits converts an array of PsiElements to an array of LSP TextEdits.
// If element is a PsiNamedElement, the edit will be applied to the identifier.
// Otherwise, the edit will be applied to the entire element.
pub fn elements_to_text_edits(elements []psi.PsiElement, new_name string) []lsp.TextEdit {
	mut result := []lsp.TextEdit{cap: elements.len}

	for element in elements {
		range := if element is psi.PsiNamedElement {
			element.identifier_text_range()
		} else {
			element.text_range()
		}
		result << lsp.TextEdit{
			range: text_range_to_lsp_range(range)
			new_text: new_name
		}
	}

	return result
}

pub fn position_to_lsp_position(pos psi.Position) lsp.Position {
	return lsp.Position{
		line: pos.line
		character: pos.character
	}
}

pub fn lsp_position_to_position(pos lsp.Position) psi.Position {
	return psi.Position{
		line: pos.line
		character: pos.character
	}
}
