module psi

pub interface StubElement {
	id() StubId
	name() string
	stub_type() StubType
	parent_stub() ?&StubElement
	children_stubs() []StubElement
	get_children_by_type(typ StubType) []StubElement
	parent_of_type(typ StubType) ?StubElement
	get_psi() ?PsiElement
	is_valid() bool
}
