module indexer

struct PerFileCache {
pub mut:
	data map[string]Cache
}
