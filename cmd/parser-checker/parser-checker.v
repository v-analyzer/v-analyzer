module main

import analyzer.psi
import analyzer.parser
import os
import time

fn main() {
	gen_res := os.execute('cd tree_sitter_v && tree-sitter generate')
	if gen_res.exit_code != 0 {
		panic('tree-sitter generate failed: ${gen_res.output}')
	}
	types_res := os.execute('cd tree_sitter_v && v run generate_types.vsh')
	if types_res.exit_code != 0 {
		panic('generate_types.vsh failed: ${types_res.output}')
	}
	time.sleep(1 * time.second)

	path := './cmd/parser-checker/testdata/test.v'
	res := parser.parse_file(path)!
	psi_file := psi.new_psi_file(path, res.tree, res.source_text)

	mut visitor := psi.PrinterVisitor{}
	psi_file.root().accept_mut(mut visitor)
	visitor.print()
}
