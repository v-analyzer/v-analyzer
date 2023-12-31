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
module attributes

// Flag attribute mark enum as bitfield.
//
// Example:
// ```
// [flag]
// enum Permissions {
//   read  // = 0b0001
//   write // = 0b0010
//   other // = 0b0100
// }
// ```
//
// Here, each subsequent element will increase the value of the previous one
// by shifting to the left.
//
// For an enum with a flag attribute, the special methods `has()` and `all()` can be used.
//
// ```
// [flag]
// enum Permissions {
//   read  // = 0b0001
//   write // = 0b0010
//   other // = 0b0100
// }
//
// fn main() {
//   p := Permissions.read
//   assert p.has(.read | .other) // test if *at least one* of the flags is set
//
//   p1 := Permissions.read | .write
//   assert p1.has(.write)
//   assert p1.all(.read | .write) // test if *all* of the flags is set
// }
// ```
@[attribute]
pub struct Flag {
	name            string = 'flag'
	with_arg        bool
	arg_is_optional bool
	target          []Target = [Target.enum_]
}
