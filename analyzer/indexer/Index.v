module indexer

import json
import time

// IndexNotFoundError возвращается, если индекс не найден.
pub struct IndexNotFoundError {
	Error
}

// NeedReindexedError возвращается, если индекс необходимо перестроить.
pub struct NeedReindexedError {
	Error
}

// IndexVersionMismatchError возвращается, если версия индекса не совпадает с последней.
pub struct IndexVersionMismatchError {
	Error
}

// Index инкапсулирует логику хранения индекса.
pub struct Index {
pub:
	version string = '4'
pub mut:
	updated_at time.Time // время последнего обновления индекса
	data       PerFileCache
}

// decode инкапсулирует логику декодирования индекса.
// Если индекс был поврежден и его не удалось декодировать, возвращается ошибка.
// Если версия индекса не совпадает с последней, возвращается ошибка IndexVersionMismatchError.
pub fn (mut i Index) decode(data string) ! {
	res := json.decode(Index, data) or { return error('Failed to decode index') }
	if res.version != i.version {
		return IndexVersionMismatchError{}
	}
	i.data = res.data
}

// encode инкапсулирует логику кодирования индекса.
pub fn (i &Index) encode() string {
	return json.encode(i)
}
