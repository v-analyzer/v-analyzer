module main

import testing

mut t := testing.Tester{}

t.test('struct field completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		struct FooStruct {
			name string
		}

		fn main() {
			foo := FooStruct{}
			foo./*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()
	if items.len == 0 {
		t.fail('no completion variants')
		return
	}

	first := items.first()
	if first.label != 'name' {
		t.fail('expected "name" but got ' + first.label)
	}
})

t.test('variables completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			name := 100
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()
	if items.len == 0 {
		t.fail('no completion variants')
		return
	}

	first := items.first()
	if first.label != 'name' {
		t.fail('expected "name" but got ' + first.label)
	}
})

t.test('simple variable definition', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			name := 100
			println(na/*caret*/me)
		}
	'.trim_indent())!

	locations := fixture.definition_at_cursor()
	if locations.len == 0 {
		t.fail('not found definition')
		return
	}

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_eq(fixture.text_at_range(first.target_selection_range), 'name')
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
	if locations.len == 0 {
		t.fail('not found definition')
		return
	}

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_eq(fixture.text_at_range(first.target_selection_range), 'name')
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
	if locations.len == 0 {
		t.fail('not found definition')
		return
	}

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_eq(fixture.text_at_range(first.target_selection_range), 'index')
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
	if locations.len == 0 {
		t.fail('not found definition')
		return
	}

	first := locations.first()
	t.assert_uri(first.target_uri, fixture.current_file_uri())
	t.assert_eq(fixture.text_at_range(first.target_selection_range), 'index')
})

t.stats()
