module psi

// StubList описывает способ хранения всех стабов в конкретном файле.
// Хранение стабов в виде таблицы эффективнее, чем хранение в виде дерева,
// а также позволяет проще сериализовать стабы в файл.
[heap]
pub struct StubList {
pub mut:
	module_name string
	path        string
	index_map   map[StubId]&StubBase
	child_map   map[StubId][]int
}

fn (s StubList) root() &StubBase {
	return s.index_map[0]
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

fn (s &StubList) first_child(id StubId) ?&StubElement {
	stub := s.get_stub(id)?
	children_ids := s.child_map[stub.id()]
	if children_ids.len == 0 {
		return none
	}

	child_id := children_ids.first()
	return s.index_map[child_id]
}

fn (s &StubList) last_child(id StubId) ?&StubElement {
	stub := s.get_stub(id)?
	children_ids := s.child_map[stub.id()]
	if children_ids.len == 0 {
		return none
	}

	child_id := children_ids.last()
	return s.index_map[child_id]
}

fn (s &StubList) get_children_stubs(id StubId) []StubElement {
	stub_ids := s.child_map[id]
	mut stubs := []StubElement{cap: stub_ids.len}
	for stub_id in stub_ids {
		stubs << s.index_map[stub_id]
	}
	return stubs
}

fn (s &StubList) prev_sibling(id StubId) ?&StubElement {
	stub := s.get_stub(id)?
	parent := stub.parent_stub()?

	children_ids := s.child_map[parent.id()]
	index := children_ids.index(id)
	if index == 0 || index == -1 {
		return none
	}

	prev_id := children_ids[index - 1]
	return s.index_map[prev_id]
}

fn (s StubList) get_stub(id StubId) ?&StubBase {
	return s.index_map[id] or { return none }
}
