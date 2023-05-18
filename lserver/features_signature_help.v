module lserver

import lsp
import analyzer.psi

pub fn (mut ls LanguageServer) signature_help(params lsp.SignatureHelpParams, mut wr ResponseWriter) ?lsp.SignatureHelp {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return none }

	println('signature help at ' + params.position.str() + ' in file ' + file.uri)

	offset := file.find_offset(params.position)
	element := file.psi_file.find_element_at(offset) or {
		println('cannot find element at ' + offset.str())
		return none
	}

	call := element.parent_of_type_or_self(.call_expression) or {
		println('cannot find call expression at ' + offset.str())
		return none
	}

	if call is psi.CallExpression {
		if resolved := call.resolve() {
			if resolved is psi.FunctionOrMethodDeclaration {
				ctx := params.context
				active_parameter := call.parameter_index_on_offset(offset)

				if ctx.is_retrigger {
					mut help := ctx.active_signature_help
					help.active_parameter = active_parameter
					return help
				}

				signature := resolved.signature()?
				parameters := signature.parameters()

				mut param_infos := []lsp.ParameterInformation{}
				for parameter in parameters {
					param_infos << lsp.ParameterInformation{
						label: parameter.get_text()
					}
				}

				return lsp.SignatureHelp{
					active_parameter: active_parameter
					signatures: [
						lsp.SignatureInformation{
							label: 'fn ${resolved.name()}${signature.get_text()}'
							parameters: param_infos
						},
					]
				}
			}
		}
	}

	return none
}
