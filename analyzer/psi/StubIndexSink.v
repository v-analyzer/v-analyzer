module psi

[heap]
pub struct StubIndexSink {
pub mut:
	stub_id          StubId
	stub_list        &StubList // List of stubs in the current file for which the index is being built.
	module_name      string
	imported_modules []string
	kind             StubIndexLocationKind
	data             map[int]map[string][]StubId
}

const non_fqn_keys = [StubIndexKey.global_variables, .methods_fingerprint, .fields_fingerprint,
	.interface_methods_fingerprint, .interface_fields_fingerprint, .methods]

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	resulting_value := if s.module_name != '' && key !in psi.non_fqn_keys {
		s.module_name + '.' + value
	} else {
		value
	}

	mut values := s.data[int(key)].move()
	values[resulting_value] << s.stub_id
	s.data[int(key)] = values.move()
}
