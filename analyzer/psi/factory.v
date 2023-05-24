module psi

import analyzer.parser

pub fn create_file_from_text(text string) &PsiFileImpl {
	res := parser.parse_code(text)
	return new_psi_file('dummy.v', res.tree, text)
}
