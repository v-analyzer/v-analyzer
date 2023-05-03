module lserver

import lsp

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) ?lsp.Hover {
	return lsp.Hover{
		contents: lsp.hover_markdown_string('hello')
		range: lsp.Range{}
	}
}
