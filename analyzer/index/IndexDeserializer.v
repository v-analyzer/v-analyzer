module index

import analyzer.psi
import bytes
import time

pub struct IndexDeserializer {
mut:
	d bytes.Deserializer
}

pub fn new_index_deserializer(data []u8) IndexDeserializer {
	return IndexDeserializer{
		d: bytes.new_deserializer(data)
	}
}

pub fn (mut d IndexDeserializer) deserialize_index() Index {
	version := d.d.read_string()
	updated_at_unix := d.d.read_i64()
	file_indexes := d.deserialize_file_indexes()

	return Index{
		version: version
		updated_at: time.unix(updated_at_unix)
		per_file: PerFileIndex{
			data: file_indexes
		}
	}
}

pub fn (mut d IndexDeserializer) deserialize_file_indexes() map[string]FileIndex {
	len := d.d.read_int()
	mut file_indexes := map[string]FileIndex{}
	for _ in 0 .. len {
		file_index := d.deserialize_file_index()
		file_indexes[file_index.filepath] = file_index
	}
	return file_indexes
}

pub fn (mut d IndexDeserializer) deserialize_file_index() FileIndex {
	filepath := d.d.read_string()
	file_last_modified := d.d.read_i64()
	module_name := d.d.read_string()
	module_fqn := d.d.read_string()

	stub_list := d.deserialize_stub_list()
	stub_index_sink := d.deserialize_stub_index_sink(stub_list)

	return FileIndex{
		filepath: filepath
		file_last_modified: file_last_modified
		module_name: module_name
		module_fqn: module_fqn
		stub_list: stub_list
		sink: stub_index_sink
	}
}

pub fn (mut d IndexDeserializer) deserialize_stub_index_sink(stub_list &psi.StubList) &psi.StubIndexSink {
	len := d.d.read_int()
	mut sink := &psi.StubIndexSink{}
	for _ in 0 .. len {
		key := d.d.read_u8()
		mut sink_map := d.deserialize_stub_index_sink_map(stub_list)
		sink.data[key] = sink_map.move()
	}
	return sink
}

pub fn (mut d IndexDeserializer) deserialize_stub_index_sink_map(stub_list &psi.StubList) map[string]psi.StubInfo {
	len := d.d.read_int()
	mut sink_map := map[string]psi.StubInfo{}
	for _ in 0 .. len {
		key := d.d.read_string()
		stub_id := d.d.read_int()
		sink_map[key] = psi.StubInfo{
			stub_id: stub_id
			stub_list: stub_list
		}
	}
	return sink_map
}

pub fn (mut d IndexDeserializer) deserialize_stub_list() &psi.StubList {
	path := d.d.read_string()
	mut child_map := map[psi.StubId][]int{}
	len := d.d.read_int()
	for _ in 0 .. len {
		id := d.d.read_int()
		children_len := d.d.read_int()
		mut children := []int{cap: children_len}
		for _ in 0 .. children_len {
			children << d.d.read_int()
		}
		child_map[id] = children
	}

	stubs_count := d.d.read_int()
	mut stubs := []&psi.StubBase{cap: stubs_count}
	for _ in 0 .. stubs_count {
		stubs << d.deserialize_stub()
	}

	mut index_map := map[psi.StubId]&psi.StubBase{}
	for stub in stubs {
		index_map[stub.id] = stub
	}

	mut list := &psi.StubList{}
	list.path = path
	list.index_map = index_map.move()
	list.child_map = child_map.move()

	for _, mut stub in list.index_map {
		stub.stub_list = list

		parent := list.index_map[stub.parent_id] or { continue }
		stub.parent = parent
	}

	return list
}

pub fn (mut d IndexDeserializer) deserialize_stub() &psi.StubBase {
	text := d.d.read_string()
	comment := d.d.read_string()
	receiver := d.d.read_string()
	name := d.d.read_string()

	line := d.d.read_int()
	column := d.d.read_int()
	end_line := d.d.read_int()
	end_column := d.d.read_int()

	parent_id := d.d.read_int()
	stub_type := unsafe { psi.StubType(d.d.read_u8()) }
	id := d.d.read_u8()

	return &psi.StubBase{
		text: text
		comment: comment
		receiver: receiver
		name: name
		text_range: psi.TextRange{
			line: line
			column: column
			end_line: end_line
			end_column: end_column
		}
		parent_id: parent_id
		stub_type: stub_type
		id: id
	}
}
