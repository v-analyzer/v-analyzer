// Copyright (c) 2022 Petr Makhnev. All rights reserved.
// Use of this source code is governed by a MIT
// license that can be found in the LICENSE file.
module attributes

// Unsafe attribute mark the function as unsafe, so
// function can be called only from unsafe code.
//
// Example:
// ```
// [unsafe]
// fn foo() {}
//
// fn main() {
//   foo() // warning: function `foo` must be called from an `unsafe` block
//
//   unsafe {
//     foo() // ok
//   }
// }
// ```
[attribute]
pub struct Unsafe {
	name            string   = 'unsafe'
	with_arg        bool     = false
	arg_is_optional bool     = false
	target          []Target = [Target.function]
}
