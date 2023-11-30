module psi

import analyzer.psi.types

pub struct InterfaceFieldDeclaration {
	PsiElementImpl
}

pub fn (f &InterfaceFieldDeclaration) is_embedded_definition() bool {
	return f.has_child_of_type(.embedded_definition)
}

pub fn (f &InterfaceFieldDeclaration) doc_comment() string {
	if stub := f.get_stub() {
		return stub.comment
	}

	if comment := f.find_child_by_type(.comment) {
		return comment.get_text().trim_string_left('//').trim(' \t')
	}

	return extract_doc_comment(f)
}

pub fn (f &InterfaceFieldDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier)
}

pub fn (f InterfaceFieldDeclaration) identifier_text_range() TextRange {
	if stub := f.get_stub() {
		return stub.identifier_text_range
	}

	identifier := f.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (f &InterfaceFieldDeclaration) name() string {
	if stub := f.get_stub() {
		return stub.name
	}

	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f &InterfaceFieldDeclaration) get_type() types.Type {
	return infer_type(f)
}

pub fn (f &InterfaceFieldDeclaration) owner() ?PsiElement {
	return f.parent_of_type(.interface_declaration)
}

pub fn (f &InterfaceFieldDeclaration) scope() ?&InterfaceFieldScope {
	element := f.sibling_of_type_backward(.interface_field_scope)?
	if element is InterfaceFieldScope {
		return element
	}
	return none
}

pub fn (f &InterfaceFieldDeclaration) is_mutable() bool {
	scope := f.scope() or { return false }
	return scope.is_mutable()
}

pub fn (f &InterfaceFieldDeclaration) is_public() bool {
	return true
}

pub fn (_ InterfaceFieldDeclaration) stub() {}
