module psi

import analyzer.parser

pub fn create_file_from_text(text string) &PsiFileImpl {
	res := parser.parse_code(text)
	return new_psi_file('dummy.v', AstNode(res.tree.root_node()), res.rope)
}

pub fn create_type_reference_expression(name string) &TypeReferenceExpression {
	file := create_file_from_text('a := ${name}{}')
	element := file.root().find_element_at(6) or { panic('no element at 6') }
	parent := element.parent() or { panic('no parent') }
	if parent is TypeReferenceExpression {
		return parent
	}
	panic('element at 7 is not TypeReferenceExpression')
}
