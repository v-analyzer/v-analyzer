module indexer

pub struct FunctionCache {
pub:
	filepath string
	name     string
}

struct Cache {
pub mut:
	filepath  string
	functions []FunctionCache
}
