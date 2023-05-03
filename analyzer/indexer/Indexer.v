module indexer

import lsp
import os
import analyzer.parser
import time
import sync
import runtime

// Indexer инкапсулирует в себе логику индексации проекта
// и предоставляет интерфейс для работы с индексом.
pub struct Indexer {
pub mut:
	index Index
}

pub fn new() Indexer {
	return Indexer{
		index: Index{
			data: &PerFileCache{}
		}
	}
}

pub fn (mut i Indexer) need_index(path string) bool {
	if path.ends_with('/net/http/mime/db.v') {
		return false
	}

	return path.ends_with('.v') && !path.ends_with('_test.v') && !path.contains('/tests/')
		&& !path.contains('/slow_tests/') && !path.contains('/linux_bare/old/')
		&& !path.ends_with('.js.v')
}

pub fn (mut i Indexer) index(root lsp.DocumentUri) {
	now := time.now()
	println('Indexing root ${root}')

	file_chan := chan string{cap: 1000}
	cache_chan := chan Cache{cap: 1000}

	spawn fn [root, mut i, file_chan] () {
		path := root.path()
		os.walk(path, fn [mut i, file_chan] (path string) {
			if i.need_index(path) {
				file_chan <- path
			}
		})

		file_chan.close()
	}()

	spawn fn [cache_chan, file_chan, mut i] () {
		mut wg := sync.new_waitgroup()
		workers := runtime.nr_cpus() - 4
		wg.add(workers)
		for j := 0; j < workers; j++ {
			spawn fn [file_chan, mut wg, mut i, cache_chan] () {
				for {
					file := <-file_chan or { break }
					cache_chan <- i.index_file(file) or {
						println('Error indexing ${file}: ${err}')
					}
				}

				wg.done()
			}()
		}

		wg.wait()
		cache_chan.close()
	}()

	mut caches := []Cache{cap: 100}
	for {
		cache := <-cache_chan or { break }
		caches << cache
	}

	for cache in caches {
		i.index.data.data[cache.filepath] = cache
	}

	println('Indexing finished')
	println('Indexing took ${time.since(now)} seconds')
}

pub fn (mut i Indexer) index_file(path string) !Cache {
	content := os.read_file(path)!
	res := parser.parse_code(content)
	cache := Cache{
		filepath: path
	}
	mut visitor := &IndexingVisitor{
		filepath: path
		file: res
		cache: &cache
	}
	res.accept(mut visitor)
	return cache
}
