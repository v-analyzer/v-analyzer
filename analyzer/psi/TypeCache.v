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
@[translated]
module psi

import analyzer.psi.types
import sync
import loglib

__global type_cache = TypeCache{}

pub struct TypeCache {
mut:
	mutex sync.RwMutex
	data  map[string]types.Type
}

pub fn (t &TypeCache) get(element PsiElement) ?types.Type {
	t.mutex.@rlock()
	defer {
		t.mutex.runlock()
	}

	fingerprint := t.element_fingerprint(element)
	return t.data[fingerprint] or { return none }
}

pub fn (mut t TypeCache) put(element PsiElement, typ types.Type) types.Type {
	t.mutex.@lock()
	defer {
		t.mutex.unlock()
	}

	fingerprint := t.element_fingerprint(element)
	t.data[fingerprint] = typ
	return typ
}

pub fn (mut t TypeCache) clear() {
	t.mutex.@lock()
	defer {
		t.mutex.unlock()
	}

	loglib.with_fields({
		'cache_size': t.data.len.str()
	}).log_one(.info, 'Clearing type cache')

	t.data = map[string]types.Type{}
}

@[inline]
fn (_ &TypeCache) element_fingerprint(element PsiElement) string {
	range := element.text_range()
	return '${element.containing_file.path}:${element.node.type_name}:${range.line}:${range.column}:${range.end_column}:${range.end_line}'
}
