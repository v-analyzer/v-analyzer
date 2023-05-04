module ir

struct Finder {
	pos int
mut:
	found []Node = [null_node]
}

fn (mut f Finder) visit(node Node) bool {
	pos := node_pos(node)
	offset := pos.offset
	len := pos.len
	if f.pos >= offset && f.pos < offset + len {
		f.found << node
		return true
	}
	return true
}

pub fn find_element_at(node Node, pos int) Node {
	mut finder := Finder{
		pos: pos
	}
	node.accept(mut finder)

	return finder.found.last()
}

pub fn find_reference_at(node Node, pos int) ?Node {
	mut finder := Finder{
		pos: pos
	}
	node.accept(mut finder)

	for found in finder.found.reverse() {
		if found is ReferenceExpression {
			return found
		}
	}

	return none
}

pub fn node_pos(n Node) Pos {
	start := n.node.start_point()
	end := n.node.end_point()
	return Pos{
		offset: n.node.start_byte()
		len: n.node.end_byte() - n.node.start_byte()
		start: Point{
			line: start.row
			col: start.column
		}
		end: Point{
			line: end.row
			col: end.column
		}
	}
}
