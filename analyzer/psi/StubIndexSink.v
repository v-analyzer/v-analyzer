module psi

pub struct StubInfo {
pub:
	stub_id   StubId
	stub_list &StubList
}

[heap]
pub struct StubIndexSink {
pub mut:
	stub_id   StubId
	stub_list &StubList
	data      map[int]map[string]StubInfo
}

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	mut values := s.data[int(key)].move()
	values[value] = StubInfo{
		stub_id: s.stub_id
		stub_list: s.stub_list
	}
	s.data[int(key)] = values.move()
}
