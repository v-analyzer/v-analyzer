module indexer

// PerFileCache описывает кэш группы файлов в индексе.
pub struct PerFileCache {
pub mut:
	data map[string]FileCache
}

pub fn (p &PerFileCache) get_all_functions() []FunctionCache {
	mut res := []FunctionCache{}
	for _, datum in p.data {
		res << datum.functions
	}
	return res
}

pub fn (p &PerFileCache) get_all_symbols() []CachedNamedSymbol {
	mut res := []CachedNamedSymbol{}
	for _, datum in p.data {
		for function in datum.functions {
			res << CachedNamedSymbol(function)
		}
		for struct_ in datum.structs {
			res << CachedNamedSymbol(struct_)
		}
	}
	return res
}
