module psi

[heap]
pub struct StubIndexSink {
pub mut:
	stub_id     StubId
	stub_list   &StubList // List of stubs in the current file for which the index is being built.
	module_name string
	kind        StubIndexLocationKind
	data        map[int]map[string][]StubId
}

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	resulting_value := if s.module_name != '' {
		s.module_name + '.' + value
	} else {
		value
	}

	mut values := s.data[int(key)].move()
	values[resulting_value] << s.stub_id
	s.data[int(key)] = values.move()
}
