module psi

[heap]
pub struct StubIndexSink {
pub mut:
	stub_id   StubId
	stub_list &StubList // Список стаблв в текущем файле для которого строится индекс
	data      map[int]map[string][]StubId
}

fn (mut s StubIndexSink) occurrence(key StubIndexKey, value string) {
	mut values := s.data[int(key)].move()
	values[value] << s.stub_id
	s.data[int(key)] = values.move()
}
