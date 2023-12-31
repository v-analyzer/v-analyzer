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
import analyzer.psi

pub fn (mut ls LanguageServer) folding_range(params lsp.FoldingRangeParams) ?[]lsp.FoldingRange {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	mut result := []lsp.FoldingRange{}

	for node in psi.new_tree_walker(file.psi_file.root().node) {
		if node.type_name == .import_list {
			element := psi.create_element(node, file.psi_file)
			decls := element.find_children_by_type(.import_declaration)
			if decls.len < 2 {
				continue
			}

			first := decls.first()
			range := element.text_range()

			first_range := if first is psi.ImportDeclaration {
				spec := first.spec() or { continue }
				spec.text_range()
			} else {
				continue
			}

			result << lsp.FoldingRange{
				start_line: first_range.line
				start_character: first_range.column
				end_line: range.end_line - 2
				end_character: range.end_column
				kind: lsp.folding_range_kind_imports
			}
		}
	}

	return result
}
