module indexer

import json

// Index инкапсулирует логику хранения индекса.
pub struct Index {
pub:
	version string = '0.0.1'
pub mut:
	data &PerFileCache
}

pub fn (mut i Index) decode(data string) ! {
	res := json.decode(PerFileCache, data) or { return error('Failed to decode index') }
	i.data = &res
}

pub fn (i &Index) encode() string {
	return json.encode(i.data)
}
