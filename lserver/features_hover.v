module lserver

import lsp
import lserver.documentation
import time

pub fn (mut ls LanguageServer) hover(params lsp.HoverParams, mut wr ResponseWriter) ?lsp.Hover {
	watch := time.new_stopwatch(auto_start: true)
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	println('hovering at ' + params.position.str() + ' in file ' + file.uri)

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return none
	}

	mut provider := documentation.Provider{}
	doc_element := provider.find_documentation_element(element)?
	if content := provider.documentation(doc_element) {
		println('Time to hover: ' + watch.elapsed().str())
		return lsp.Hover{
			contents: lsp.hover_markdown_string(content)
			range: text_range_to_lsp_range(element.text_range())
		}
	}

	if grand := element.parent_nth(2) {
		parent := element.parent()?
		this := element.type_name() + ': ' + element.node.type_name.str()
		parent_elem := parent.type_name() + ': ' + parent.node.type_name.str()
		grand_elem := grand.type_name() + ': ' + grand.node.type_name.str()
		return lsp.Hover{
			contents: lsp.hover_markdown_string('```\n' + grand_elem + '\n  ' + parent_elem +
				'\n   ' + this + '\n```')
			range: text_range_to_lsp_range(element.text_range())
		}
	}

	return lsp.Hover{
		contents: lsp.hover_markdown_string(element.type_name() + ': ' +
			element.node.type_name.str())
		range: text_range_to_lsp_range(element.text_range())
	}
}
