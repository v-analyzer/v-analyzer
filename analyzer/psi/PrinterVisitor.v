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
module psi

import arrays

pub struct PrinterVisitor {
mut:
	indent     int
	lines      []string
	text_lines []string
}

fn (mut r PrinterVisitor) visit_element(element PsiElement) {
	if !r.visit_element_impl(element) {
		return
	}
	mut child := element.first_child() or { return }
	r.indent += 1
	for {
		child.accept_mut(mut r)
		child = child.next_sibling() or { break }
	}
	r.indent -= 1
}

fn (mut r PrinterVisitor) visit_element_impl(element PsiElement) bool {
	r.lines << '  '.repeat(r.indent) + '${element.node.type_name}'
	r.text_lines << '${element.get_text()}'
	return true
}

pub fn (r &PrinterVisitor) print() {
	max_line_width := arrays.max(r.lines.map(it.len)) or { 0 }
	for i, line in r.lines {
		text_lines := r.text_lines[i].split_into_lines()
		if text_lines.len == 0 {
			println('<empty>')
		} else if text_lines.len == 1 {
			println(line + ' '.repeat(max_line_width - line.len) + ' | ' + r.text_lines[i])
		} else {
			println(line + ' '.repeat(max_line_width - line.len) + ' | ' + text_lines[0])
			for j in 1 .. text_lines.len {
				println(' '.repeat(max_line_width) + ' | ' + text_lines[j].trim_string_left('  '))
			}
		}
	}
}
