module testing

import analyzer.psi

pub struct Tester {
mut:
	tests        []&Test
	last_fixture &Fixture
}

pub fn (mut t Tester) create_or_reuse_fixture() &Fixture {
	if !isnil(t.last_fixture) {
		return t.last_fixture
	}

	mut fixture := new_fixture()
	fixture.initialize() or {
		println('Cannot initialize fixture: ${err}')
		return fixture
	}

	t.last_fixture = fixture
	return fixture
}

pub fn (mut t Tester) stats() {
	mut passed := 0
	mut failed := 0
	mut skipped := 0

	for test in t.tests {
		if test.state == .skipped {
			skipped += 1
		} else if test.state == .failed {
			failed += 1
		} else {
			passed += 1
		}
	}

	println('Passed: ${passed}, Failed: ${failed}, Skipped: ${skipped}')
}

pub fn (mut t Tester) test(name string, test_func fn (mut test Test, mut fixture Fixture) !) {
	mut fixture := t.create_or_reuse_fixture()

	mut test := &Test{
		name: name
	}
	t.tests << test
	test_func(mut test, mut fixture) or { println('Test failed: ${err}') }

	test.print()
}

pub fn (mut t Tester) type_test(name string, filepath string) {
	mut fixture := t.create_or_reuse_fixture()

	mut test := &Test{
		name: name
	}
	t.tests << test

	fixture.configure_by_file(filepath) or {
		println('Cannot configure fixture: ${err}')
		return
	}
	file := fixture.ls.get_file(fixture.current_file.uri()) or {
		println('File not found: ${fixture.current_file.uri()}')
		return
	}

	mut expr_calls := []psi.CallExpression{}
	mut expr_calls_ptr := &expr_calls

	psi.inspect(file.psi_file.root, fn [mut expr_calls_ptr] (it psi.PsiElement) bool {
		if it is psi.CallExpression {
			expr := it.expression() or { return true }
			text := expr.get_text()
			if text != 'expr_type' {
				return true
			}

			arguments := it.arguments()
			if arguments.len != 2 {
				return true
			}

			expr_calls_ptr << it
			return false
		}
		return true
	})

	for call in expr_calls {
		arguments := call.arguments()
		if arguments.len != 2 {
			continue
		}

		first := arguments[0]
		second := arguments[1]

		if first is psi.PsiTypedElement {
			typ := first.get_type()
			got_type_string := typ.readable_name()

			if second is psi.Literal {
				first_child := second.first_child() or { continue }
				if first_child is psi.StringLiteral {
					expected_type_string := first_child.content()

					if expected_type_string != got_type_string {
						test.state = .failed
						test.message = '
						In file ${call.containing_file.path}:${call.text_range().line}

						Type mismatch.
						Expected: ${expected_type_string}
						Found: ${got_type_string}

					'.trim_indent()
						break
					}
				}
			}
		}
	}

	test.print()
}

pub fn (mut t Tester) scratch_test(name string, test_func fn (mut test Test, mut fixture Fixture) !) {
	mut fixture := new_fixture()
	fixture.initialize() or {
		println('Test failed: ${err}')
		return
	}

	mut test := &Test{
		name: name
	}
	t.tests << test
	test_func(mut test, mut fixture) or { println('Test failed: ${err}') }

	test.print()
}
