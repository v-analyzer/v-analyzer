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
module types

fn types_foo(a string) string {}

fn types_foo1(a string) (int, string) {}

fn types_foo2(a string, b int) (int, string) {}

fn types_foo3(a string, b int) {}

fn types_foo4() {}

fn main() {
	expr_type(types_foo, 'fn (string) string')
	expr_type(types_foo1, 'fn (string) (int, string)')
	expr_type(types_foo2, 'fn (string, int) (int, string)')
	expr_type(types_foo3, 'fn (string, int)')
	expr_type(types_foo4, 'fn ()')

	expr_type(fn () {}, 'fn ()')
	expr_type(fn (i int) {}, 'fn (int)')
	expr_type(fn (i int) string {}, 'fn (int) string')
	expr_type(fn (i int, s string) string {}, 'fn (int, string) string')
}

fn calls() {
	func := fn (i int) string {}
	expr_type(func(), 'string')

	func1 := fn (i int) int {}
	expr_type(func1(), 'int')
}
