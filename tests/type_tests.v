module main

import testing

mut t := testing.Tester{}

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

t.stats()
