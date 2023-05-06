module analyzer

import lsp
import analyzer.psi

pub struct OpenedFile {
pub mut:
	uri      lsp.DocumentUri
	version  int
	text     string
	psi_file psi.PsiFileImpl
}

pub fn (f OpenedFile) find_offset(pos lsp.Position) u32 {
	return u32(compute_offset(f.psi_file.text(), pos.line, pos.character))
	// lines := f.text.split_into_lines()
	// if pos.line >= lines.len {
	// 	return u32(f.text.len)
	// }
	// return u32(lines[..pos.line].join('\n').len + pos.character)
}

pub fn (f OpenedFile) fqn(name string) string {
	module_name := f.psi_file.module_name() or { return name }

	if module_name == '' || module_name == 'builtin' || module_name == 'main' {
		return name
	}

	return module_name + '.' + name
}
