module indexer

// PerFileCache описывает кэш группы файлов в индексе.
pub struct PerFileCache {
pub mut:
	data map[string]FileCache
}
