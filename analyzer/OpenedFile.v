module analyzer

import lsp
import analyzer.psi

pub struct OpenedFile {
pub mut:
	uri      lsp.DocumentUri
	version  int
	psi_file &psi.PsiFileImpl
}

pub fn (f OpenedFile) find_offset(pos lsp.Position) u32 {
	return u32(compute_offset(f.psi_file.text(), pos.line, pos.character))
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
