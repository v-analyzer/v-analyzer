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
module stubs

// This file contains definitions of compile time reflection.

// $int describes any integer type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $int {
//     println(f.name)
//   }
// }
// ```
pub const $int = TypeInfo{}

// $float describes any float type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $float {
//     println(f.name)
//   }
// }
// ```
pub const $float = TypeInfo{}

// $array describes any array type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $array {
//     println(f.name)
//   }
// }
// ```
pub const $array = TypeInfo{}

// $map describes any map type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $map {
//     println(f.name)
//   }
// }
// ```
pub const $map = TypeInfo{}

// $struct describes any struct type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $struct {
//     println(f.name)
//   }
// }
// ```
pub const $struct = TypeInfo{}

// $interface describes any interface type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $interface {
//     println(f.name)
//   }
// }
// ```
pub const $interface = TypeInfo{}

// $enum describes any enum type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $enum {
//     println(f.name)
//   }
// }
// ```
pub const $enum = TypeInfo{}

// $alias describes any alias type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $alias {
//     println(f.name)
//   }
// }
// ```
pub const $alias = TypeInfo{}

// $sumtype describes any sumtype type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $sumtype {
//     println(f.name)
//   }
// }
// ```
pub const $sumtype = TypeInfo{}

// $function describes any function type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $function {
//     println(f.name)
//   }
// }
// ```
pub const $function = TypeInfo{}

// $option describes any option type.
//
// Example:
// ```
// $for f in Test.fields {
//   $if f.typ is $option {
//     println(f.name)
//   }
// }
// ```
pub const $option = TypeInfo{}

struct CompileTimeTypeInfo {
pub:
	// fields describes the list of structure fields.
	// This field can only be used inside `$for`.
	//
	// Example:
	// ```v
	// struct Foo {
	//   a int
	//   b string
	// }
	//
	// fn main() {
	//   $for field in Foo.fields {
	//     println(field.name)
	//   }
	// }
	// ```
	fields []FieldData
}
