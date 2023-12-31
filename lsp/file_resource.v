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
module lsp

pub struct CreateFileOptions {
	overwrite        bool
	ignore_if_exists bool @[json: ignoreIfExists]
}

pub struct CreateFile {
	kind    string = 'create'
	uri     DocumentUri
	options CreateFileOptions
}

pub struct RenameFileOptions {
	overwrite        bool
	ignore_if_exists bool @[json: ignoreIfExists]
}

pub struct RenameFile {
	kind    string = 'rename'
	old_uri DocumentUri       @[json: oldUri]
	new_uri DocumentUri       @[json: newUri]
	options RenameFileOptions
}

pub struct DeleteFileOptions {
	recursive        bool
	ignore_if_exists bool @[json: ignoreIfExists]
}

pub struct DeleteFile {
	kind    string = 'delete'
	uri     DocumentUri
	options DeleteFileOptions
}
