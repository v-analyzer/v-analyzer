module testing

import term
import lsp
import time
import strings

pub enum TestState {
	passed
	failed
	skipped
}

pub struct Test {
mut:
	name     string
	state    TestState
	message  string
	duration time.Duration
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
	mut sb := strings.new_builder(100)
	sb.write_string('${t.duration:10} ')

	if t.state == .failed {
		sb.write_string(term.red('[FAILED] '))
		sb.write_string(t.name)
		sb.write_string('\n')
		sb.write_string('  ${t.message}\n')
	} else if t.state == .passed {
		sb.write_string(term.green('[PASSED] '))
		sb.write_string(t.name)
		sb.write_string('\n')
	}

	print(sb.str())
}
