// Copyright (c) 2019-2023 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module builtin

import strconv

pub struct string {
pub:
	str &u8 = 0 // points to a C style 0 terminated string of bytes.
	len int // the length of the .str field, excluding the ending 0 byte. It is always equal to strlen(.str).
	// NB string.is_lit is an enumeration of the following:
	// .is_lit == 0 => a fresh string, should be freed by autofree
	// .is_lit == 1 => a literal string from .rodata, should NOT be freed
	// .is_lit == -98761234 => already freed string, protects against double frees.
	// ---------> ^^^^^^^^^ calling free on these is a bug.
	// Any other value means that the string has been corrupted.
mut:
	is_lit int
}

// runes returns an array of all the utf runes in the string `s`
// which is useful if you want random access to them
[direct_array_access]
pub fn (s string) runes() []rune {
	mut runes := []rune{cap: s.len}
	for i := 0; i < s.len; i++ {
		char_len := utf8_char_len(unsafe { s.str[i] })
		if char_len > 1 {
			end := if s.len - 1 >= i + char_len { i + char_len } else { s.len }
			mut r := unsafe { s[i..end] }
			runes << r.utf32_code()
			i += char_len - 1
		} else {
			runes << unsafe { s.str[i] }
		}
	}
	return runes
}
