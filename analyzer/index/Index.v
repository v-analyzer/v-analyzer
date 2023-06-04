module index

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
	version string = '13'
pub mut:
	updated_at time.Time // время последнего обновления индекса
	per_file   PerFileIndex
}

// decode инкапсулирует логику декодирования индекса.
// Если индекс был поврежден и его не удалось декодировать, возвращается ошибка.
// Если версия индекса не совпадает с последней, возвращается ошибка IndexVersionMismatchError.
pub fn (mut i Index) decode(data []u8) ! {
	mut d := new_index_deserializer(data)
	index := d.deserialize_index(i.version)!
	i.per_file = index.per_file
}

// encode инкапсулирует логику кодирования индекса.
pub fn (i &Index) encode() []u8 {
	mut s := IndexSerializer{}
	s.serialize_index(i)
	return s.s.data
}
