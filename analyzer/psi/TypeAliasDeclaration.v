module psi

pub struct TypeAliasDeclaration {
	PsiElementImpl
}

pub fn (a &TypeAliasDeclaration) is_public() bool {
	modifiers := a.visibility_modifiers() or { return false }
	return modifiers.is_public()
}

pub fn (a &TypeAliasDeclaration) module_name() string {
	return stubs_index.get_module_qualified_name(a.containing_file.path)
}

pub fn (a TypeAliasDeclaration) doc_comment() string {
	if a.stub_id != non_stubbed_element {
		if stub := a.stubs_list.get_stub(a.stub_id) {
			return stub.comment
		}
	}
	return extract_doc_comment(a)
}

pub fn (a &TypeAliasDeclaration) types() []PlainType {
	types := a.find_children_by_type_or_stub(.plain_type)
	mut result := []PlainType{cap: types.len}
	for type_ in types {
		if type_ is PlainType {
			result << type_
		}
	}
	return result
}

pub fn (a TypeAliasDeclaration) identifier() ?PsiElement {
	return a.find_child_by_type(.identifier) or { return none }
}

pub fn (a &TypeAliasDeclaration) identifier_text_range() TextRange {
	if a.stub_id != non_stubbed_element {
		if stub := a.stubs_list.get_stub(a.stub_id) {
			return stub.text_range
		}
	}

	identifier := a.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (a TypeAliasDeclaration) name() string {
	if a.stub_id != non_stubbed_element {
		if stub := a.stubs_list.get_stub(a.stub_id) {
			return stub.name
		}
	}

	identifier := a.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (a TypeAliasDeclaration) visibility_modifiers() ?&VisibilityModifiers {
	modifiers := a.find_child_by_type_or_stub(.visibility_modifiers)?
	if modifiers is VisibilityModifiers {
		return modifiers
	}
	return none
}

fn (_ &TypeAliasDeclaration) stub() {}
