[translated]
module psi

__global stubs_index = StubIndex{}

pub struct StubIndex {
pub:
	sinks []StubIndexSink
}

pub fn new_stubs_index(sinks []StubIndexSink) &StubIndex {
	return &StubIndex{
		sinks: sinks
	}
}

pub fn (s &StubIndex) get_elements(key StubIndexKey, name string) []PsiElement {
	mut elements := []PsiElement{}
	for sink in s.sinks {
		elements << s.get_elements_from_sink(key, name, sink)
	}
	return elements
}

fn (s &StubIndex) get_elements_from_sink(key StubIndexKey, name string, sink StubIndexSink) []PsiElement {
	data := sink.data[key] or { return [] }
	println('found data: len: ${data.len}')

	stub_info := data[name] or { return [] }

	println('found stub_info: ${stub_info.stub_id}')

	stub := stub_info.stub_list.index_map[stub_info.stub_id] or { return [] }

	println('found stub: ${stub.id}')

	return [
		StubbedElementType{}.create_psi(stub) or { return [] },
	]
}
