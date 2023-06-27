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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
	t.assert_definition_name(first, 'name')
})

t.test('variable definition from outer scope after inner scope', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			if true {
				println(na/*caret*/me)
			}
			name := 100
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_no_definition(locations)!
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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
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
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
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

t.test('field definition', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		module field_definition_test

		struct Foo {
			name string
		}

		fn main() {
			foo := Foo{}
			println(foo.na/*caret*/me)
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!
	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
	t.assert_definition_name(first, 'name')
})

t.test('method definition', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		module method_definition_test

		struct Foo {
			name string
		}

		fn (foo Foo) get_name() string {
			return foo.name
		}

		fn main() {
			foo := Foo{}
			println(foo.get_na/*caret*/me())
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!
	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
	t.assert_definition_name(first, 'get_name')
})

t.test('top level variable', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		name := 100
		println(na/*caret*/me)
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
	t.assert_definition_name(first, 'name')
})

t.test('top level variable from outer scope', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		name := 100
		if true {
			println(na/*caret*/me)
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())!
	t.assert_definition_name(first, 'name')
})

t.test('shell script implicit os module', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.vsh', '
		abs_/*caret*/path()
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri_from_stdlib(first.target_uri, 'filepath.v')!
})

t.test('shell script implicit os module contstant', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.vsh', '
		ar/*caret*/gs
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	t.assert_has_definition(locations)!

	first := locations.first()
	t.assert_uri_from_stdlib(first.target_uri, 'os.c.v')!
})

t.stats()
