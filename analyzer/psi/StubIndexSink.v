module psi

pub struct StubInfo {
	stub_id   StubId
	stub_list &StubList
}

[heap]
pub struct StubIndexSink {
pub mut:
	stub_id   StubId
	stub_list &StubList
	data      map[StubIndexKey]map[string]StubInfo
}

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	mut values := s.data[key].move()
	values[value] = StubInfo{
		stub_id: s.stub_id
		stub_list: s.stub_list
	}
	s.data[key] = values.move()
}
