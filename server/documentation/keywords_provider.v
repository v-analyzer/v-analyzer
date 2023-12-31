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
module documentation

import strings
import analyzer.psi
import analyzer.psi.types

// KeywordProvider unlike `Provider` creates documentation not for named elements i
// but for language keywords.
// This documentation is used to educate users of the language and as an entry point
// to the language documentation.
pub struct KeywordProvider {
mut:
	sb strings.Builder = strings.new_builder(100)
}

pub fn (mut p KeywordProvider) documentation(element psi.PsiElement) ?string {
	text := element.get_text()

	if text == 'chan' {
		p.chan_documentation()
		return p.sb.str()
	}

	return none
}

fn (mut p KeywordProvider) chan_documentation() ? {
	struct_ := psi.find_struct(types.chan_init_type.qualified_name())?
	doc := struct_.doc_comment()
	p.sb.write_string(doc)
}
