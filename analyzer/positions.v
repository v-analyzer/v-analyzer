module analyzer

import tree_sitter

// compute_offset returns a byte offset from the given position
pub fn compute_offset(src tree_sitter.SourceText, line int, col int) int {
	mut offset := 0
	mut src_line := 0
	mut src_col := 0
	src_len := src.len()
	for i := 0; i < src_len; i++ {
		byt := src.at(i)
		is_lf := byt == `\n`
		is_crlf := i + 1 < src_len && unsafe { byt == `\r` && src.at(i + 1) == `\n` }
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
