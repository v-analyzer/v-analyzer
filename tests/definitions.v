module main

import testing

mut t := testing.Tester{}

t.test('simple variable definition', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			name := 100
			println(na/*caret*/me)
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'name')
})

t.test('variable definition from outer scope', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			name := 100
			if true {
				println(na/*caret*/me)
			}
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'name')
})

t.test('variable definition from for loop', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			for index := 0; index < 100; index++ {
				println(inde/*caret*/x)
			}
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'index')
})

t.test('variable definition from for in loop', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			for index in 0 .. 100 {
				println(inde/*caret*/x)
			}
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'index')
})

t.test('variable definition from if unwrapping', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			if value := foo() {
				println(val/*caret*/ue)
			}
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'value')
})

// TODO: This probably should be prohibited
t.test('variable definition from if unwrapping in else', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			if value := foo() {

			} else {
				println(val/*caret*/ue)
			}
 		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_definition_name(first, 'value')
})

t.test('variable definition from if unwrapping from outside', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			if value := foo() {}

			println(val/*caret*/ue)
 		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_no_definition(locations)!
})

t.stats()
