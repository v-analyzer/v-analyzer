module testing

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
