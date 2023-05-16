module psi

pub enum StubIndexKey {
	functions
	structs
	constants
	type_aliases
}

pub interface IndexSink {
mut:
	occurrence(key StubIndexKey, value string)
}

pub interface StubBasedPsiElement {
	name() string
	stub() ?&StubBase
}
