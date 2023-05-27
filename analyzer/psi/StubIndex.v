[translated]
module psi

__global stubs_index = StubIndex{}

pub struct StubIndex {
pub:
	sinks           []StubIndexSink
	user_code_sinks []StubIndexSink
}

pub fn new_stubs_index(sinks []StubIndexSink, user_code_sinks []StubIndexSink) &StubIndex {
	return &StubIndex{
		sinks: sinks
		user_code_sinks: user_code_sinks
	}
}

pub fn (s &StubIndex) get_all_elements_by_key(key StubIndexKey) []PsiElement {
	mut elements := []PsiElement{cap: s.sinks.len * 10}
	for sink in s.sinks {
		elements << s.get_all_elements_from_sink_by_key(key, sink)
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_workspace() []PsiElement {
	mut elements := []PsiElement{cap: s.user_code_sinks.len * 10}
	for sink in s.user_code_sinks {
		$for key in StubIndexKey.fields {
			elements << s.get_all_elements_from_sink_by_key(key, sink)
		}
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_workspace_by_key(key StubIndexKey) []PsiElement {
	mut elements := []PsiElement{cap: s.user_code_sinks.len * 10}
	for sink in s.user_code_sinks {
		elements << s.get_all_elements_from_sink_by_key(key, sink)
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_file(file string) []PsiElement {
	mut elements := []PsiElement{cap: s.user_code_sinks.len * 10}
	for sink in s.user_code_sinks {
		if sink.stub_list.path != file {
			continue
		}

		$for key in StubIndexKey.values {
			elements << s.get_all_elements_from_sink_by_key(key.value, sink)
		}
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_module(name string) []PsiElement {
	mut elements := []PsiElement{cap: s.sinks.len * 10}
	for sink in s.sinks {
		if sink.stub_list.module_name != name {
			continue
		}

		$for key in StubIndexKey.values {
			elements << s.get_all_elements_from_sink_by_key(key.value, sink)
		}
	}
	return elements
}

pub fn (s &StubIndex) get_all_elements_from_file_by_key(key StubIndexKey, file string) []PsiElement {
	mut elements := []PsiElement{}
	for sink in s.sinks {
		if sink.stub_list.path != file {
			continue
		}

		elements << s.get_all_elements_from_sink_by_key(key, sink)
	}
	return elements
}

pub fn (s &StubIndex) get_elements_by_name(key StubIndexKey, name string) []PsiElement {
	mut elements := []PsiElement{}
	for sink in s.sinks {
		elements << s.get_elements_from_sink_by_name(key, name, sink)
	}
	return elements
}

fn (_ &StubIndex) get_elements_from_sink_by_name(key StubIndexKey, name string, sink StubIndexSink) []PsiElement {
	data := sink.data[int(key)] or { return [] }
	stub_ids := data[name] or { return [] }

	mut result := []PsiElement{cap: stub_ids.len}
	for stub_id in stub_ids {
		stub := sink.stub_list.index_map[stub_id] or { continue }
		result << StubbedElementType{}.create_psi(stub) or { continue }
	}

	return result
}

fn (_ &StubIndex) get_all_elements_from_sink_by_key(key StubIndexKey, sink StubIndexSink) []PsiElement {
	data := sink.data[int(key)] or { return [] }

	mut elements := []PsiElement{cap: data.len}
	for _, stub_ids in data {
		for stub_id in stub_ids {
			stub := sink.stub_list.index_map[stub_id] or { continue }
			elements << StubbedElementType{}.create_psi(stub) or { continue }
		}
	}

	return elements
}

pub fn (s &StubIndex) get_module_qualified_name(file string) string {
	for sink in s.sinks {
		if sink.stub_list.path != file {
			continue
		}

		return sink.stub_list.module_name
	}
	return ''
}
