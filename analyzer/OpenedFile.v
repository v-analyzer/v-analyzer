module analyzer

import lsp
import analyzer.ir

pub struct OpenedFile {
pub mut:
	uri     lsp.DocumentUri
	version int
	text    string
	root    &ir.File
}

pub fn (f OpenedFile) find_offset(pos lsp.Position) int {
	lines := f.text.split_into_lines()
	if pos.line >= lines.len {
		return f.text.len
	}
	return lines[..pos.line].join('\n').len + pos.character
}

pub fn (f OpenedFile) fqn(name string) string {
	module_clause := f.root.module_clause or { return name }

	module_name := if module_clause is ir.ModuleClause {
		module_clause.name.value
	} else {
		''
	}

	if module_name == '' || module_name == 'builtin' || module_name == 'main' {
		return name
	}

	return module_name + '.' + name
}
