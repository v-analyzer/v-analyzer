module psi

// StubElement описывает интерфейс любого стаба.
pub interface StubElement {
	id() StubId
	name() string
	text() string
	receiver() string
	stub_type() StubType
	parent_stub() ?&StubElement
	first_child() ?&StubElement
	children_stubs() []StubElement
	get_child_by_type(typ StubType) ?StubElement
	get_children_by_type(typ StubType) []StubElement
	prev_sibling() ?&StubElement
	parent_of_type(typ StubType) ?StubElement
	get_psi() ?PsiElement
}

pub fn is_valid_stub(s StubElement) bool {
	if s is StubBase {
		return !isnil(s) && !isnil(s.stub_list)
	}
	return !isnil(s)
}
