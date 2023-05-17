module psi

pub enum StubIndexKey {
	functions
	methods
	structs
	constants
	type_aliases
	enums
}

pub interface IndexSink {
mut:
	occurrence(key StubIndexKey, value string)
}

pub interface StubBasedPsiElement {
	name() string
	stub() ?&StubBase
}
