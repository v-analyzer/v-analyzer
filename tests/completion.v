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

t.stats()
