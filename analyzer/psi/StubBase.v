module psi

import tree_sitter_v as v

pub type StubId = int

const non_stubbed_element = StubId(-1)

pub enum StubType as u8 {
	root
	function_declaration
	signature
	struct_declaration
	field_declaration
	constant_declaration
	builtin_type
}

[heap]
pub struct StubBase {
pub:
	name       string
	text       string
	comment    string
	text_range TextRange
	stub_list  &StubList
	parent     &StubElement
	stub_type  StubType
pub mut:
	id StubId
}

pub fn new_stub_base(parent &StubElement, stub_type StubType, name string, text string, text_range TextRange) &StubBase {
	return new_stub_base_with_comment(parent, stub_type, name, text, '', text_range)
}

pub fn new_stub_base_with_comment(parent &StubElement, stub_type StubType, name string, text string, comment string, text_range TextRange) &StubBase {
	mut stub_list := if parent is StubBase {
		if !isnil(parent.stub_list) { parent.stub_list } else { &StubList{} }
	} else {
		&StubList{}
	}
	mut stub := &StubBase{
		name: name
		text: text
		comment: comment
		text_range: text_range
		stub_list: stub_list
		parent: unsafe { parent }
		stub_type: stub_type
	}
	stub_list.add_stub(mut stub, parent)
	return stub
}

pub fn new_root_stub(path string) &StubBase {
	mut stub_list := &StubList{
		path: path
	}
	mut stub := &StubBase{
		name: '<root>'
		stub_list: stub_list
		parent: unsafe { nil }
		stub_type: .root
	}
	stub_list.add_stub(mut stub, unsafe { nil })
	return stub
}

pub fn (s &StubBase) id() StubId {
	return s.id
}

pub fn (s &StubBase) stub_type() StubType {
	return s.stub_type
}

pub fn (s &StubBase) element_type() v.NodeType {
	return match s.stub_type {
		.root { .unknown }
		.function_declaration { .function_declaration }
		.signature { .signature }
		.struct_declaration { .struct_declaration }
		.field_declaration { .struct_field_declaration }
		.constant_declaration { .const_definition }
		.builtin_type { .builtin_type }
	}
}

pub fn (s StubBase) name() string {
	return s.name
}

pub fn (s StubBase) text() string {
	return s.text
}

fn (s StubBase) get_psi() ?PsiElement {
	return StubbedElementType{}.create_psi(s)
}

fn (s &StubBase) parent_of_type(typ StubType) ?StubElement {
	mut res := &StubBase{
		...s
	}
	for {
		parent := res.parent_stub() or { return none }

		if parent is StubBase {
			res = parent
		} else {
			return none
		}

		if res.stub_type == typ {
			return res
		}
	}

	return none
}

fn (s &StubBase) parent_stub() ?&StubElement {
	if isnil(s.parent) {
		return none
	}
	return s.parent
}

fn (s &StubBase) get_children_by_type(typ StubType) []StubElement {
	return s.stub_list.get_children_stubs(s.id).filter(it.stub_type() == typ)
}

fn (s &StubBase) children_stubs() []StubElement {
	return s.stub_list.get_children_stubs(s.id)
}

fn (s &StubBase) is_valid() bool {
	return !isnil(s) && !isnil(s.stub_list)
}
