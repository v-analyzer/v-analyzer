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
module metadata

import os
import v.embed_file

struct EmbedFS {
pub mut:
	files []embed_file.EmbedFileData
}

pub fn (e &EmbedFS) unpack_to(path string) ! {
	for file in e.files {
		new_path := os.norm_path(os.join_path(path, file.path))
		dir := os.dir(new_path)
		if !os.exists(dir) {
			os.mkdir_all(dir) or { return error('failed to create directory ${dir}') }
		}
		os.write_file(new_path, file.to_string())!
	}
}

pub fn embed_fs() EmbedFS {
	mut files := []embed_file.EmbedFileData{}
	files << $embed_file('stubs/arrays.v', .zlib)
	files << $embed_file('stubs/primitives.v', .zlib)
	files << $embed_file('stubs/vweb.v', .zlib)
	files << $embed_file('stubs/compile_time_constants.v', .zlib)
	files << $embed_file('stubs/compile_time_reflection.v', .zlib)
	files << $embed_file('stubs/builtin_compile_time.v', .zlib)
	files << $embed_file('stubs/channels.v', .zlib)
	files << $embed_file('stubs/README.md', .zlib)
	files << $embed_file('stubs/attributes/Deprecated.v', .zlib)
	files << $embed_file('stubs/attributes/Table.v', .zlib)
	files << $embed_file('stubs/attributes/Attribute.v', .zlib)
	files << $embed_file('stubs/attributes/DeprecatedAfter.v', .zlib)
	files << $embed_file('stubs/attributes/Unsafe.v', .zlib)
	files << $embed_file('stubs/attributes/Flag.v', .zlib)
	files << $embed_file('stubs/attributes/Noreturn.v', .zlib)
	files << $embed_file('stubs/attributes/Manualfree.v', .zlib)
	files << $embed_file('stubs/implicit.v', .zlib)
	files << $embed_file('stubs/compile_time.v', .zlib)
	files << $embed_file('stubs/c_decl.v', .zlib)
	files << $embed_file('stubs/errors.v', .zlib)
	files << $embed_file('stubs/threads.v', .zlib)
	files << $embed_file('v.mod', .zlib)

	return EmbedFS{
		files: files
	}
}
