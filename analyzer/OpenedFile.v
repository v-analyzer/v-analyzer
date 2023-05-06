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
