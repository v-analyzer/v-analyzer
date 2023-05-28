module main

import testing
import lserver.completion.providers

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

	t.assert_has_completion_with_label(items, 'name')!
})

t.test('assert inside test file', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1_test.v', '
		fn test_something() {
			asse/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'assert expr')!
	t.assert_has_completion_with_label(items, 'assert expr, message')!
})

t.test('assert as expression', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1_test.v', '
		fn test_something() {
			a := asse/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_no_completion_with_label(items, 'assert expr')!
	t.assert_no_completion_with_label(items, 'assert expr, message')!
})

t.test('assert outside test file', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn test_something() {
			asse/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_no_completion_with_label(items, 'assert expr')!
	t.assert_no_completion_with_label(items, 'assert expr, message')!
})

t.test('attributes over function', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		[/*caret*/]
		fn main() {

		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'direct_array_access')!
	t.assert_has_completion_with_label(items, "sql: 'value'")!
})

t.test('json attribute for field', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		struct Foo {
			some_value string [js/*caret*/]
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, "json: 'someValue'")!
})

t.test('compile time constant', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		@/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, '@FN')!
	t.assert_has_completion_with_label(items, '@FILE_LINE')!
})

t.test('function like keywords', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'dump()')!
	t.assert_has_completion_with_label(items, 'sizeof()')!
	t.assert_has_completion_with_label(items, 'typeof()')!
	t.assert_has_completion_with_label(items, 'isreftype()')!
	t.assert_has_completion_with_label(items, '__offsetof()')!
})

t.test('inits completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'chan int{}')!
	t.assert_has_completion_with_label(items, 'map[string]int{}')!
	t.assert_has_completion_with_label(items, 'thread int{}')!
})

t.test('keywords completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'true')!
	t.assert_has_completion_with_label(items, 'false')!
	t.assert_has_completion_with_label(items, 'static')!
	t.assert_has_completion_with_label(items, 'none')!
})

t.test('continue and break inside loop', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		for {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'break')!
	t.assert_has_completion_with_label(items, 'continue')!
})

t.test('continue and break outside loop', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_no_completion_with_label(items, 'break')!
	t.assert_no_completion_with_label(items, 'continue')!
})

t.test('module name completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		modu/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()
	if items.len == 0 {
		t.fail('no completion variants')
		return
	}

	t.assert_has_completion_with_label(items, 'module main')!
	t.assert_has_completion_with_label(items, 'module spavn_analyzer_test')!
})

t.test('module name completion with module clause', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		module main
		modu/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_no_completion_with_label(items, 'module main')!
	t.assert_no_completion_with_label(items, 'module spavn_analyzer_test')!
})

t.test('nil keyword completion outside unsafe', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_insert_test(items, 'unsafe { nil }')!
})

t.test('nil keyword completion inside unsafe', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		unsafe {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_insert_test(items, 'nil')!
})

t.test('or block completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		foo() /*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'or { ... }')!
	t.assert_has_completion_with_label(items, 'or { panic(err) }')!
})

t.test('unsafe block completion as expression', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		a := /*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_insert_test(items, 'unsafe { $0 }')!
})

t.test('unsafe block completion as statements', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_insert_test(items, 'unsafe {\n\t$0\n}')!
})

t.test('defer block completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'defer { ... }')!
})

t.test('return completion inside function without return type', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn foo() {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'return')!
})

t.test('return completion inside function with return type', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn foo() int {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'return ')!
})

t.test('return completion inside function with bool return type', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn foo() bool {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'return ')!
	t.assert_has_completion_with_label(items, 'return true')!
	t.assert_has_completion_with_label(items, 'return false')!
})

t.test('top level completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	for label, _ in providers.top_level_map {
		t.assert_has_completion_with_label(items, label)!
		t.assert_has_completion_with_label(items, 'pub ${label}')!
	}
})

t.test('no top level completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		fn main() {
			/*caret*/
		}
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	for label, _ in providers.top_level_map {
		t.assert_no_completion_with_label(items, label)!
		t.assert_no_completion_with_label(items, 'pub ${label}')!
	}
})

t.test('imported modules completion', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
	fixture.configure_by_text('1.v', '
		import arrays
		import net.http
		import foo as bar
		import bar.baz as qux

		/*caret*/
	'.trim_indent())!

	items := fixture.complete_at_cursor()

	t.assert_has_completion_with_label(items, 'arrays')!
	t.assert_has_completion_with_label(items, 'http')!
	t.assert_no_completion_with_label(items, 'foo')!
	t.assert_has_completion_with_label(items, 'bar')!
	t.assert_no_completion_with_label(items, 'baz')!
	t.assert_has_completion_with_label(items, 'qux')!
})

t.stats()
