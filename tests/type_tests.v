module main

import testing

mut t := testing.Tester{}

t.type_test('literals', 'types/literals.v')
t.type_test('parameters types', 'types/parameters.v')
t.type_test('call expressions', 'types/call_expression.v')
t.type_test('type initializer', 'types/type_initializer.v')

t.stats()
