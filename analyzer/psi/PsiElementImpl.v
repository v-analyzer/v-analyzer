module psi

import tree_sitter_v as v

pub struct PsiElementImpl {
pub:
	id              ID
	node            AstNode // базовый узел из Tree Sitter
	containing_file &PsiFileImpl
	// stubs related
	stub_id    StubId = non_stubbed_element
	stubs_list &StubList
}

pub fn new_psi_node(id ID, containing_file &PsiFileImpl, node AstNode) PsiElementImpl {
	return PsiElementImpl{
		id: id
		node: node
		containing_file: containing_file
	}
}

fn new_psi_node_from_stub(id StubId, stubs_list &StubList) PsiElementImpl {
	return PsiElementImpl{
		node: AstNode{}
		containing_file: new_stub_psi_file(stubs_list.path, stubs_list)
		stub_id: id
		stubs_list: stubs_list
	}
}

// pub fn (n PsiElementImpl) str() string {
// 	return "ast node ${n.node.type_name} at ${n.node.start_point()}"
// }

pub fn (n PsiElementImpl) node() AstNode {
	return n.node
}

pub fn (n PsiElementImpl) stub_list() &StubList {
	return n.stubs_list
}

pub fn (n PsiElementImpl) element_type() v.NodeType {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.element_type()
		}
	}
	if isnil(n.node) {
		return .unknown
	}
	return n.node.type_name
}

pub fn (n PsiElementImpl) containing_file() &PsiFileImpl {
	if n.stub_id != non_stubbed_element {
		path := n.stubs_list.path
		return new_stub_psi_file(path, n.stubs_list)
	}

	return n.containing_file
}

pub fn (n PsiElementImpl) is_equal(other PsiElement) bool {
	if n.stub_id != non_stubbed_element {
		return n.stub_id == other.stub_id
	}

	return n.get_text() == other.get_text()
}

pub fn (n PsiElementImpl) accept(visitor PsiElementVisitor) {
	visitor.visit_element(n)
}

pub fn (n PsiElementImpl) accept_mut(mut visitor MutablePsiElementVisitor) {
	visitor.visit_element(n)
}

pub fn (n PsiElementImpl) find_element_at(offset u32) ?PsiElement {
	abs_offset := n.node.start_byte() + offset
	el := n.node.descendant_for_byte_range(abs_offset, abs_offset)
	return create_element(el, n.containing_file)
}

pub fn (n PsiElementImpl) find_reference_at(offset u32) ?PsiElement {
	element := n.find_element_at(offset)?
	if element is ReferenceExpressionBase {
		return element as PsiElement
	}
	if element is Identifier {
		parent := element.parent()?
		if parent is ReferenceExpressionBase {
			return parent as PsiElement
		}
	}
	return none
}

pub fn (n PsiElementImpl) parent() ?PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			parent := stub.parent_stub() or { return none }
			if parent.is_valid() {
				return parent.get_psi()
			}
			return none
		}
	}

	parent := n.node.parent() or { return none }
	return create_element(parent, n.containing_file)
}

pub fn (n PsiElementImpl) parent_nth(depth int) ?PsiElement {
	parent := n.node.parent_nth(depth) or { return none }
	return create_element(parent, n.containing_file)
}

pub fn (n PsiElementImpl) parent_of_type(typ v.NodeType) ?PsiElement {
	mut res := PsiElement(n)
	for {
		res = res.parent() or { return none }
		if res.node.type_name == typ {
			return res
		}
	}

	return none
}

pub fn (n PsiElementImpl) sibling_of_type_backward(typ v.NodeType) ?PsiElement {
	mut res := PsiElement(n)
	for {
		res = res.prev_sibling() or { return none }
		if res.node.type_name == typ {
			return res
		}
	}

	return none
}

pub fn (n PsiElementImpl) parent_of_type_or_self(typ v.NodeType) ?PsiElement {
	if n.node.type_name == typ {
		return create_element(n.node, n.containing_file)
	}
	mut parent := n.parent() or { return none }
	if parent.node.type_name == typ {
		return parent
	}

	for {
		parent = parent.parent() or { return none }
		if parent.node.type_name == typ {
			return parent
		}
	}

	return none
}

pub fn (n PsiElementImpl) children() []PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			children := stub.children_stubs()
			mut result := []PsiElement{cap: children.len}
			for child in children {
				result << child.get_psi() or { continue }
			}
			return result
		}
	}

	mut result := []PsiElement{}
	mut child := n.node.first_child() or { return [] }
	for {
		result << create_element(child, n.containing_file)
		child = child.next_sibling() or { break }
	}
	return result
}

pub fn (n PsiElementImpl) first_child() ?PsiElement {
	child := n.node.first_child() or { return none }
	return create_element(child, n.containing_file)
}

pub fn (n PsiElementImpl) first_child_or_stub() ?PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			child := stub.first_child() or { return none }
			return child.get_psi()
		}
	}

	child := n.node.first_child() or { return none }
	return create_element(child, n.containing_file)
}

pub fn (n PsiElementImpl) last_child() ?PsiElement {
	child := n.node.last_child() or { return none }
	return create_element(child, n.containing_file)
}

pub fn (n PsiElementImpl) last_child_or_stub() ?PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			child := stub.last_child() or { return none }
			return child.get_psi()
		}
	}

	child := n.node.last_child() or { return none }
	return create_element(child, n.containing_file)
}

pub fn (n PsiElementImpl) next_sibling() ?PsiElement {
	sibling := n.node.next_sibling() or { return none }
	return create_element(sibling, n.containing_file)
}

pub fn (n PsiElementImpl) prev_sibling() ?PsiElement {
	sibling := n.node.prev_sibling() or { return none }
	return create_element(sibling, n.containing_file)
}

pub fn (n PsiElementImpl) find_child_by_type(typ v.NodeType) ?PsiElement {
	ast_node := n.node.first_node_by_type(typ) or { return none }
	return create_element(ast_node, n.containing_file)
}

pub fn (n PsiElementImpl) find_child_by_type_or_stub(typ v.NodeType) ?PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			child := stub.get_child_by_type(node_type_to_stub_type(typ)) or { return none }
			return child.get_psi()
		}
	}

	ast_node := n.node.first_node_by_type(typ) or { return none }
	return create_element(ast_node, n.containing_file)
}

pub fn (n PsiElementImpl) find_child_by_name(name string) ?PsiElement {
	ast_node := n.node.child_by_field_name(name) or { return none }
	return create_element(ast_node, n.containing_file)
}

pub fn (n PsiElementImpl) find_children_by_type(typ v.NodeType) []PsiElement {
	mut result := []PsiElement{}
	mut child := n.node.first_child() or { return [] }
	for {
		if child.type_name == typ {
			result << create_element(child, n.containing_file)
		}
		child = child.next_sibling() or { break }
	}
	return result
}

pub fn (n PsiElementImpl) find_children_by_type_or_stub(typ v.NodeType) []PsiElement {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			child := stub.get_children_by_type(node_type_to_stub_type(typ))
			mut result := []PsiElement{cap: child.len}
			for c in child {
				result << c.get_psi() or { continue }
			}
			return result
		}
	}

	mut result := []PsiElement{}
	mut child := n.node.first_child() or { return [] }
	for {
		if child.type_name == typ {
			result << create_element(child, n.containing_file)
		}
		child = child.next_sibling() or { break }
	}
	return result
}

pub fn (n PsiElementImpl) find_last_child_by_type(typ v.NodeType) ?PsiElement {
	ast_node := n.node.last_node_by_type(typ) or { return none }
	return create_element(ast_node, n.containing_file)
}

pub fn (n PsiElementImpl) get_text() string {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.text
		}
	}

	return n.node.text(n.containing_file.source_text)
}

pub fn (n PsiElementImpl) text_range() TextRange {
	if n.stub_id != non_stubbed_element {
		if stub := n.stubs_list.get_stub(n.stub_id) {
			return stub.text_range
		}
	}

	return TextRange{
		line: int(n.node.start_point().row)
		column: int(n.node.start_point().column)
		end_line: int(n.node.end_point().row)
		end_column: int(n.node.end_point().column)
	}
}
