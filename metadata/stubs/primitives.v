// Copyright (c) 2022-2023 Petr Makhnev. All rights reserved.
// Use of this source code is governed by a MIT
// license that can be found in the LICENSE file.
module stubs

// This file contains definitions of primitive types V.

// bool is the set of boolean values, true and false.
pub type bool = bool

// u8 is the set of all unsigned 8-bit integers.
// Range: 0 through 255.
pub type u8 = u8

// u16 is the set of all unsigned 16-bit integers.
// Range: 0 through 65535.
pub type u16 = u16

// u32 is the set of all unsigned 32-bit integers.
// Range: 0 through 4294967295.
pub type u32 = u32

// u64 is the set of all unsigned 64-bit integers.
// Range: 0 through 18446744073709551615.
pub type u64 = u64

// usize is platform-dependent unsigned integer type.
pub type usize = u64

// i8 is the set of all signed 8-bit integers.
// Range: -128 through 127.
pub type i8 = i8

// i16 is the set of all signed 16-bit integers.
// Range: -32768 through 32767.
pub type i16 = i16

// i32 is the set of all signed 32-bit integers.
// Range: -2147483648 through 2147483647.
pub type i32 = int

// int is the set of all signed 32-bit integers.
// Range: -2147483648 through 2147483647.
pub type int = int

// i64 is the set of all signed 64-bit integers.
// Range: -9223372036854775808 through 9223372036854775807.
pub type i64 = i64

// isize is platform-dependent integer type.
pub type isize = i64

// f32 is the set of all IEEE-754 32-bit floating-point numbers.
pub type f32 = f32

// f64 is the set of all IEEE-754 64-bit floating-point numbers.
pub type f64 = f64

// byte is an alias for u8 and is equivalent to u8 in all ways. It is
// used, by convention, to distinguish byte values from 8-bit unsigned
// integer values.
pub type byte = u8

// rune is an alias for int and is equivalent to int in all ways. It is
// used, by convention, to distinguish character values from integer values.
pub type rune = int

// char is an alias for u8 and is equivalent to u8 in all ways.
// Mostly used for [C interoperability](https://docs.vosca.dev/advanced-concepts/v-and-c.html).
pub type char = u8

// voidptr is an untyped pointer.
// Mostly used for [C interoperability](https://docs.vosca.dev/advanced-concepts/v-and-c.html).
pub type voidptr = voidptr

// byteptr is a byte pointer.
// Mostly used for [C interoperability](https://docs.vosca.dev/advanced-concepts/v-and-c.html).
pub type byteptr = byteptr

// charptr is a char pointer.
// Mostly used for [C interoperability](https://docs.vosca.dev/advanced-concepts/v-and-c.html).
pub type charptr = charptr
