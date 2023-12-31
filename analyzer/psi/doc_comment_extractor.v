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

import strings

pub fn extract_doc_comment(el PsiElement) string {
	mut comment := el.prev_sibling() or { return '' }
	if comment !is Comment {
		comment = comment.prev_sibling() or { return '' }
	}

	mut comments := []PsiElement{}

	for comment is Comment {
		func_start_line := el.node.start_point().row
		comment_start_line := comment.node.start_point().row

		if comment_start_line + 1 + u32(comments.len) != func_start_line {
			break
		}

		comments << comment
		comment = comment.prev_sibling() or { break }
	}

	comments.reverse_in_place()

	lines := comments.map(it.get_text()
		.trim_string_left('//')
		.trim_string_left(' ')
		.trim_right(' \t'))

	mut res := strings.new_builder(lines.len * 40)

	mut inside_code_block := false

	for raw_line in lines {
		line := raw_line.trim_right(' ')

		// when `--------` line
		if line.replace('-', '').len == 0 && line.len != 0 {
			res.write_string('\n\n')
			continue
		}

		is_end_of_sentence := line.ends_with('.') || line.ends_with('!') || line.ends_with('?')
			|| line.ends_with(':')
		is_list := line.starts_with('-')
		is_header := line.starts_with('#')
		is_table := line.starts_with('|') || line.starts_with('|')
		is_example := line.starts_with('Example:')
		is_code_block := line.starts_with('```')

		if is_example || (is_code_block && !inside_code_block) {
			res.write_string('\n')
		}

		without_example_label := line.trim_string_left('Example:').trim_space()
		if is_example && without_example_label.len != 0 {
			res.write_string('\nExample:\n')
			res.write_string('```\n')
			res.write_string(without_example_label)
			res.write_string('\n')
			res.write_string('```\n')
		} else {
			res.write_string(line)
		}

		if inside_code_block || is_code_block || is_table {
			res.write_string('\n')
		}

		if (is_end_of_sentence || is_list || is_header || is_example) && !inside_code_block {
			res.write_string('\n')
		} else if !inside_code_block && !is_code_block {
			res.write_string(' ')
		}

		if is_code_block {
			inside_code_block = !inside_code_block
		}
	}

	return res.str()
}
