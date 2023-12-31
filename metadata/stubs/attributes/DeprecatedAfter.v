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

// DeprecatedAfter attribute specifies a date, after which the element will be
// considered deprecated.
//
// Before that date, calls to the function (for example) will be compiler
// notices – you will see them, but the compilation is not affected.
//
// After that date, calls will become warnings, so ordinary compiling will still
// work, but compiling with `-prod` will not (all warnings are treated like errors with `-prod`).
//
// 6 months after the deprecation date, calls will be hard
// compiler errors.
//
// Note: Must be used with `deprecated` attribute!
//
// See also [deprecated](#Deprecated) attribute.
//
// Example:
// ```
// [deprecated: 'use `foo` instead']
// [deprecated_after: '2023-05-27']
// fn boo() {}
// ```
@[attribute]
pub struct DeprecatedAfter {
	name            string = 'deprecated_after'
	with_arg        bool   = true
	arg_is_optional bool
	target          []Target = [Target.struct_, Target.function, Target.field, Target.constant,
	Target.type_alias]
}
