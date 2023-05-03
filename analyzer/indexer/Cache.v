module indexer

pub struct Pos {
pub:
	line   int
	column int
}

pub struct FunctionCache {
pub:
	filepath string
	name     string
	pos      Pos
}

pub struct StructCache {
pub:
	filepath string
	name     string
	pos      Pos
}

struct Cache {
pub mut:
	filepath  string
	functions []FunctionCache
	structs   []StructCache
}
