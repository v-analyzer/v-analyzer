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
module utils

pub fn pascal_case_to_snake_case(s string) string {
	mut res := ''
	for index, c in s {
		if c.ascii_str().is_upper() {
			if index > 0 {
				res += '_'
			}
			res += c.ascii_str().to_lower()
		} else {
			res += c.ascii_str()
		}
	}
	return res
}

pub fn snake_case_to_camel_case(s string) string {
	mut res := ''
	mut upper := false
	for c in s {
		if c == `_` {
			upper = true
		} else {
			if upper {
				res += c.ascii_str().to_upper()
				upper = false
			} else {
				res += c.ascii_str()
			}
		}
	}
	return res
}

// compute_offset returns a byte offset from the given position
pub fn compute_offset(src string, line int, col int) int {
	mut offset := 0
	mut src_line := 0
	mut src_col := 0
	src_len := src.len
	for i := 0; i < src_len; i++ {
		byt := src[i]
		is_lf := byt == `\n`
		is_crlf := i + 1 < src_len && byt == `\r` && src[i + 1] == `\n`
		is_eol := is_lf || is_crlf
		if src_line == line && src_col == col {
			return offset
		}
		if is_eol {
			if src_line == line && col > src_col {
				return -1
			}
			src_line++
			src_col = 0
			if is_crlf {
				offset += 2
				i++
			} else {
				offset++
			}
			continue
		}
		src_col++
		offset++
	}
	return offset
}
