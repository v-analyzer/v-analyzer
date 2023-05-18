module psi

import tree_sitter_v as v

pub type StubId = int

const non_stubbed_element = StubId(-1)

[params]
pub struct StubData {
pub:
	text     string
	comment  string
	receiver string
}

[heap]
pub struct StubBase {
	StubData
pub:
	name       string
	text_range TextRange
	parent_id  StubId
	stub_type  StubType
pub mut:
	stub_list &StubList
	parent    &StubElement
	id        StubId
}

pub fn new_stub_base(parent &StubElement, stub_type StubType, name string, text_range TextRange, data StubData) &StubBase {
	mut stub_list := if parent is StubBase {
		if !isnil(parent.stub_list) { parent.stub_list } else { &StubList{} }
	} else {
		&StubList{}
	}
	parent_id := if !isnil(parent) { parent.id() } else { psi.non_stubbed_element }
	mut stub := &StubBase{
		name: name
		text: data.text
		comment: data.comment
		receiver: data.receiver
		text_range: text_range
		stub_list: stub_list
		parent_id: parent_id
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
		parent_id: -1
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
		.method_declaration { .function_declaration }
		.receiver { .receiver }
		.signature { .signature }
		.struct_declaration { .struct_declaration }
		.field_declaration { .struct_field_declaration }
		.constant_declaration { .const_definition }
		.type_alias_declaration { .type_declaration }
		.plain_type { .plain_type }
		.enum_declaration { .enum_declaration }
		.enum_field_definition { .enum_field_definition }
		.struct_field_scope { .struct_field_scope }
		.attributes { .attributes }
		.attribute { .attribute }
		.attribute_expression { .attribute_expression }
		.value_attribute { .value_attribute }
	}
}

pub fn (s StubBase) name() string {
	return s.name
}

pub fn (s StubBase) text() string {
	return s.text
}

pub fn (s StubBase) receiver() string {
	return s.receiver
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

fn (s &StubBase) sibling_of_type_backward(typ StubType) ?StubElement {
	mut res := &StubBase{
		...s
	}
	for {
		prev := res.prev_sibling() or { return none }

		if prev is StubBase {
			res = prev
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
	is_nil := isnil(s.parent)
	if !is_nil {
		return s.parent
	}

	if s.parent_id == -1 {
		return none
	}

	return s.stub_list.get_stub(s.parent_id) or { return none }
}

fn (s &StubBase) get_child_by_type(typ StubType) ?StubElement {
	stubs := s.get_children_by_type(typ)
	if stubs.len == 0 {
		return none
	}
	return stubs.first()
}

fn (s &StubBase) get_children_by_type(typ StubType) []StubElement {
	return s.stub_list.get_children_stubs(s.id).filter(it.stub_type() == typ)
}

fn (s &StubBase) prev_sibling() ?&StubElement {
	return s.stub_list.prev_sibling(s.id)
}

fn (s &StubBase) children_stubs() []StubElement {
	return s.stub_list.get_children_stubs(s.id)
}

fn (s &StubBase) first_child() ?&StubElement {
	return s.stub_list.first_child(s.id)
}

fn (s &StubBase) is_valid() bool {
	return !isnil(s) && !isnil(s.stub_list)
}
