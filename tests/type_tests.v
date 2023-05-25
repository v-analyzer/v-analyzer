module main

import testing

mut t := testing.Tester{}

t.type_test('simple', 'types/literals.v')

t.stats()
