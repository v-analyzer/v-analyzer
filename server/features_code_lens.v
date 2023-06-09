module server

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) code_lens(params lsp.CodeLensParams, mut wr ResponseWriter) ?[]lsp.CodeLens {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	mut lenses := []lsp.CodeLens{}
	mut lenses_ptr := &lenses

	psi.inspect(file.psi_file.root(), fn [mut lenses_ptr, uri] (it psi.PsiElement) bool {
		if it is psi.FunctionOrMethodDeclaration {
			if it.name() == 'main' {
				start := lsp.Position{
					line: it.text_range().line
					character: it.text_range().column
				}
				lenses_ptr << lsp.CodeLens{
					range: lsp.Range{
						start: start
						end: start
					}
					command: lsp.Command{
						title: '▶ Run'
						command: 'spavn-analyzer.run'
						arguments: [
							uri.path(),
						]
					}
				}
				return false
			}
		}

		return true
	})

	return lenses
}
