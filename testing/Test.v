module testing

import term
import lsp

pub enum TestState {
	passed
	failed
	skipped
}

pub struct Test {
mut:
	name    string
	state   TestState
	message string
}

pub fn (mut t Test) fail(msg string) {
	t.state = .failed
	t.message = msg
}

pub fn (mut t Test) assert_eq[T](left T, right T) {
	if left != right {
		t.fail('expected ${left}, but got ${right}')
	}
}

pub fn (mut t Test) assert_uri(left lsp.DocumentUri, right lsp.DocumentUri) {
	if left.compare(right) != 0 {
		t.fail('expected ${left}, but got ${right}')
	}
}

pub fn (t Test) print() {
	if t.state == .failed {
		println(term.red('[FAILED]') + ' ${t.name}')
		println('  ${t.message}')
	} else if t.state == .passed {
		println(term.green('[PASSED]') + ' ${t.name}')
	}
}
