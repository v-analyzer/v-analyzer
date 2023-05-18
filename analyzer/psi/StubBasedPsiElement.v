module psi

pub enum StubIndexKey as u8 {
	functions
	methods
	structs
	constants
	type_aliases
	enums
	attributes
}

pub interface IndexSink {
mut:
	occurrence(key StubIndexKey, value string)
}

pub interface StubBasedPsiElement {
	name() string
	stub() ?&StubBase
}
