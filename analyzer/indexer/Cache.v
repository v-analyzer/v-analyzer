module indexer

pub struct FunctionCache {
pub:
	filepath string
	name     string
}

struct Cache {
pub mut:
	functions []FunctionCache
}
