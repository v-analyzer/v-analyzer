// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module index

import time

// IndexNotFoundError is returned if the index is not found.
pub struct IndexNotFoundError {
	Error
}

// NeedReindexedError is returned if the index needs to be rebuilt.
pub struct NeedReindexedError {
	Error
}

// IndexVersionMismatchError is returned if the index version does not match the latest.
pub struct IndexVersionMismatchError {
	Error
}

// Index encapsulates the index storage logic.
pub struct Index {
pub:
	version string = '33'
pub mut:
	updated_at time.Time // time of last index update
	per_file   PerFileIndex
}

// decode encapsulates the index decoding logic.
// If the index was corrupted and could not be decoded, an error is returned.
// If the index version does not match the latest, an `IndexVersionMismatchError` is returned.
pub fn (mut i Index) decode(data []u8) ! {
	mut d := new_index_deserializer(data)
	index := d.deserialize_index(i.version)!
	i.per_file = index.per_file
}

// encode encapsulates the logic for encoding an index.
pub fn (i &Index) encode() []u8 {
	mut s := IndexSerializer{}
	s.serialize_index(i)
	return s.s.data
}
