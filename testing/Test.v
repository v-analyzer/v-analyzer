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
	fixture  &Fixture
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

pub fn (mut t Test) assert_definition_name(location lsp.LocationLink, name string) {
	link_text := t.fixture.text_at_range(location.target_selection_range)
	if link_text != name {
		t.fail('expected definition "${name}", but got "${link_text}"')
	}
}

pub fn (mut t Test) assert_no_definition(locations []lsp.LocationLink) ! {
	if locations.len != 0 {
		t.fail('expected no definition, but got ${locations.len}')
		return error('expected no definition, but got ${locations.len}')
	}
}

pub fn (mut t Test) assert_has_definition(locations []lsp.LocationLink) ! {
	if locations.len == 0 {
		t.fail('no definition found')
		return error('no definition found')
	}
}

pub fn (mut t Test) assert_has_completion_with_label(items []lsp.CompletionItem, name string) ! {
	for item in items {
		if item.label == name {
			return
		}
	}

	t.fail('expected completion "${name}" not found')
	return error('expected completion "${name}" not found')
}

pub fn (mut t Test) assert_has_only_completion_with_labels(items []lsp.CompletionItem, names ...string) ! {
	if items.len != names.len {
		t.fail('expected ${names.len} completions, but got ${items.len}')
		return error('expected ${names.len} completions, but got ${items.len}')
	}

	for name in names {
		t.assert_has_completion_with_label(items, name)!
	}
}

pub fn (mut t Test) assert_has_completion_with_insert_text(items []lsp.CompletionItem, name string) ! {
	if items.len == 0 {
		t.fail('no completions found')
		return error('no completions found')
	}

	for item in items {
		if item.insert_text == name {
			return
		}
	}

	t.fail('expected completion "${name}" not found')
	return error('expected completion "${name}" not found')
}

pub fn (mut t Test) assert_no_completion_with_insert_text(items []lsp.CompletionItem, name string) ! {
	for item in items {
		if item.insert_text == name {
			t.fail('unexpected completion "${name}" found')
			return error('unexpected completion "${name}" found')
		}
	}
}

pub fn (mut t Test) assert_no_completion_with_label(items []lsp.CompletionItem, name string) ! {
	for item in items {
		if item.label == name {
			t.fail('unexpected completion "${name}" found')
			return error('unexpected completion "${name}" found')
		}
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
