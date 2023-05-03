module indexer

import lsp

// Indexer инкапсулирует в себе логику индексации проекта
// и предоставляет интерфейс для работы с индексом.
pub struct Indexer {
}

pub fn (i &Indexer) index(root lsp.DocumentUri) {
	println('Indexing ${root}')
}
