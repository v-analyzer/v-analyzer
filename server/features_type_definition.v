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
import analyzer.psi.types
import loglib

pub fn (mut ls LanguageServer) type_definition(params lsp.TextDocumentPositionParams) ?[]lsp.LocationLink {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri)?

	offset := file.find_offset(params.position)
	element := file.psi_file.find_reference_at(offset) or {
		loglib.with_fields({
			'offset': offset.str()
		}).warn('Cannot find reference')
		return none
	}

	element_text_range := element.text_range()

	resolved := element.resolve() or {
		loglib.with_fields({
			'caller': @METHOD
			'name':   element.name()
		}).warn('Cannot resolve reference')
		return none
	}

	typ := types.unwrap_generic_instantiation_type(types.unwrap_pointer_type(psi.infer_type(resolved)))
	type_element := psi.find_element(typ.qualified_name())?

	data := new_resolve_result(type_element.containing_file(), type_element) or { return [] }
	return [
		data.to_location_link(element_text_range),
	]
}
