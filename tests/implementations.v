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

fn implementations() testing.Tester {
	mut t := testing.with_name('implementations')

	t.test('method interface implementation', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo()
		}

		struct FooImpl {}

		fn (f FooImpl) foo() {}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_has_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method interface implementation with return type', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo() string
		}

		struct FooImpl {}

		fn (f FooImpl) foo() string {}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_has_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method interface implementation with parameters', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo(age int, name string) string
		}

		struct FooImpl {}

		fn (f FooImpl) foo(age int, name string) string {}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_has_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method interface implementation with parameters, parameters types mismatch',
		fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo(age int, name ?string) string
		}

		struct FooImpl {}

		fn (f FooImpl) foo(age int, name string) string {}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_no_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method interface implementation with fields', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo string
		}

		struct FooImpl {
			foo string
		}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_has_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method interface implementation with fields, types mismatch', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface /*caret*/IFoo {
			foo ?string
		}

		struct FooImpl {
			foo string
		}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_no_implementation_with_name(locations, 'FooImpl')!
	})

	t.test('method implementation', fn (mut t testing.Test, mut fixture testing.Fixture) ! {
		fixture.configure_by_text('1.v', '
		module main

		interface IFoo {
			/*caret*/foo()
		}

		struct FooImpl {}

		fn (f FooImpl) foo() {}
		'.trim_indent())!

		locations := fixture.implementation_at_cursor()
		t.assert_has_implementation_with_name(locations, 'foo')!
	})

	return t
}
