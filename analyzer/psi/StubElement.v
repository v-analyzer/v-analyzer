module psi

pub interface StubElement {
	id() StubId
	name() string
	text() string
	receiver() string
	stub_type() StubType
	parent_stub() ?&StubElement
	children_stubs() []StubElement
	get_child_by_type(typ StubType) ?StubElement
	get_children_by_type(typ StubType) []StubElement
	prev_sibling() ?&StubElement
	parent_of_type(typ StubType) ?StubElement
	get_psi() ?PsiElement
	is_valid() bool
}
