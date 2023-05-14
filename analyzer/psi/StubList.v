module psi

[heap]
pub struct StubList {
pub mut:
	path      string
	index_map map[StubId]&StubBase
	child_map map[StubId][]int
}

fn (mut s StubList) add_stub(mut stub StubBase, parent &StubElement) {
	stub_id := s.index_map.len
	stub.id = stub_id
	s.index_map[stub_id] = stub

	// add stub to parent's children
	parent_id := if parent is StubBase { parent.id } else { -1 }
	mut parent_children := s.child_map[parent_id]
	parent_children << stub_id
	s.child_map[parent_id] = parent_children
}

fn (s &StubList) get_children_stubs(id StubId) []StubElement {
	stub_ids := s.child_map[id]
	mut stubs := []StubElement{cap: stub_ids.len}
	for stub_id in stub_ids {
		stubs << s.index_map[stub_id]
	}
	return stubs
}

fn (s StubList) get_stub(id StubId) ?&StubBase {
	return s.index_map[id] or { return none }
}
