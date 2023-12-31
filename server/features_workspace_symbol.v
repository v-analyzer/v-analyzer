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
import server.tform
import analyzer.psi

pub fn (mut ls LanguageServer) workspace_symbol(_ lsp.WorkspaceSymbolParams) ?[]lsp.WorkspaceSymbol {
	workspace_elements := ls.indexing_mng.stub_index.get_all_elements_from(.workspace)

	mut workspace_symbols := []lsp.WorkspaceSymbol{cap: workspace_elements.len}

	for elem in workspace_elements {
		uri := elem.containing_file.uri()
		module_name := elem.containing_file.module_name() or { '' }

		if elem is psi.PsiNamedElement {
			name := elem.name()
			if name == '_' {
				continue
			}

			fqn := if module_name == '' { name } else { module_name + '.' + name }

			text_range := elem.identifier_text_range()
			workspace_symbols << lsp.WorkspaceSymbol{
				name: fqn
				kind: symbol_kind(elem as psi.PsiElement) or { continue }
				location: lsp.Location{
					uri: uri
					range: tform.text_range_to_lsp_range(text_range)
				}
			}
		}
	}

	return workspace_symbols
}
