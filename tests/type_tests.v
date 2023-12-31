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
module main

import testing

fn types() testing.Tester {
	mut t := testing.with_name('types')

	t.type_test('literals', 'types/literals.v')
	t.type_test('parameters types', 'types/parameters.v')
	t.type_test('call expressions', 'types/call_expression.v')
	t.type_test('type initializer', 'types/type_initializer.v')
	t.type_test('for loops', 'types/for_loops.v')
	t.type_test('slice and index expression', 'types/slice_and_index_expression.v')
	t.type_test('function literal', 'types/function_literal.v')
	t.type_test('pointers', 'types/pointers.v')
	t.type_test('bool operators', 'types/bool_operators.v')
	t.type_test('unsafe expression', 'types/unsafe_expression.v')
	t.type_test('if expression', 'types/if_expression.v')
	t.type_test('match expression', 'types/match_expression.v')
	t.type_test('map init expression', 'types/map_init_expression.v')
	t.type_test('chan type', 'types/chan_type.v')
	t.type_test('struct fields', 'types/fields.v')
	t.type_test('receiver', 'types/receiver.v')
	t.type_test('json decode', 'types/json_decode.v')
	t.type_test('generics', 'types/generics.v')
	t.type_test('constants', 'types/constants.v')
	t.type_test('for loop', 'types/for_loop.v')

	return t
}
