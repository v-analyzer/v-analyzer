[translated]
module ir

import tree_sitter
import tree_sitter_v as v

__global counter = 0

pub fn convert_file(tree &tree_sitter.Tree[v.NodeType], node TSNode, text tree_sitter.SourceText) &File {
	mut file_node := &File{
		id: counter++
		node: node
	}

	stmts_node := field_or_none(node, 'stmts') or {
		return file_node // TODO
	}

	mut stmts := []Node{}
	mut sibling := stmts_node
	for {
		stmts << convert_stmt(file_node, sibling, text) or { continue }
		sibling = sibling.next_sibling() or { break }
	}

	file_node.stmts = stmts
	file_node.module_clause = convert_node_field(file_node, node, 'module_clause', text)
	file_node.imports = convert_node_field_to[ImportList](file_node, node, 'imports',
		text)

	return file_node
}

fn convert_module_clause(parent &Node, node TSNode, text tree_sitter.SourceText) ModuleClause {
	return ModuleClause{
		id: counter++
		node: node
		name: convert_identifier(parent, field_id(node, 2), text)
		parent: parent
	}
}

fn convert_import_list(parent &Node, node TSNode, text tree_sitter.SourceText) ImportList {
	mut imports := []ImportDeclaration{}
	for i := u32(0); i < node.child_count(); i++ {
		child := node.child(i) or { continue }
		if child.type_name == .import_declaration {
			imports << convert_import_declaration(parent, child, text)
		}
	}
	return ImportList{
		id: counter++
		node: node
		imports: imports
		parent: parent
	}
}

fn convert_import_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) ImportDeclaration {
	return ImportDeclaration{
		id: counter++
		node: node
		spec: convert_import_spec(parent, node, text)
		parent: parent
	}
}

fn convert_import_spec(parent &Node, node TSNode, text tree_sitter.SourceText) ImportSpec {
	path := field(node, 'import_path')
	alias := field_opt(node, 'import_alias') or { TSNode{} }
	return ImportSpec{
		id: counter++
		node: node
		path: convert_import_path(parent, path, text)
		alias: convert_import_alias(parent, alias, text) or { Node(null_node) }
		parent: parent
	}
}

fn convert_import_path(parent &Node, node TSNode, text tree_sitter.SourceText) ImportPath {
	return ImportPath{
		id: counter++
		node: node
		value: node.text(text)
		parent: parent
	}
}

fn convert_import_alias(parent &Node, node TSNode, text tree_sitter.SourceText) ?Node {
	if node == TSNode{} {
		return none
	}
	name := field_opt(node, 'name')?
	return ImportAlias{
		id: counter++
		node: node
		name: name.text(text)
		parent: parent
	}
}

fn convert_struct_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) StructDeclaration {
	return StructDeclaration{
		id: counter++
		node: node
		name: convert_identifier(parent, field(node, 'name'), text)
		groups: convert_fields_groups(parent, field_opt(node, 'fields_groups') or { TSNode{} },
			text)
		parent: parent
	}
}

fn convert_fields_groups(parent &Node, node TSNode, text tree_sitter.SourceText) []StructFieldsGroup {
	if node.type_name == .unknown {
		return []
	}

	mut groups := []StructFieldsGroup{}
	mut sibling := node
	for {
		groups << convert_struct_fields_group(parent, sibling, text)
		sibling = sibling.next_sibling() or { break }
	}
	return groups
}

fn convert_struct_fields_group(parent &Node, node TSNode, text tree_sitter.SourceText) StructFieldsGroup {
	return StructFieldsGroup{
		id: counter++
		node: node
		fields_: convert_struct_fields(parent, node, text)
		parent: parent
	}
}

fn convert_struct_fields(parent &Node, node TSNode, text tree_sitter.SourceText) []FieldDeclaration {
	mut fields := []FieldDeclaration{}
	mut sibling := node
	for {
		if sibling.is_named() {
			fields << convert_field_declaration(parent, sibling, text) or {
				sibling = sibling.next_sibling() or { break }
				continue
			}
		}
		sibling = sibling.next_sibling() or { break }
	}
	return fields
}

fn convert_field_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) ?FieldDeclaration {
	if node.type_name == .struct_field_scope {
		return none // TODO
	}

	_ := node.child_by_field_name('name') or { return none } // TODO

	return FieldDeclaration{
		id: counter++
		node: node
		name: convert_identifier(parent, field(node, 'name'), text)
		typ: convert_type(parent, field(node, 'type'), text)
		default_value: convert_node(parent, field_opt(node, 'default_value') or { TSNode{} },
			text)
		parent: parent
	}
}

fn convert_node_field(parent &Node, node TSNode, field_name string, text tree_sitter.SourceText) Node {
	field := field_opt(node, field_name) or { return Node(null_node) }
	return convert_node(parent, field, text)
}

fn convert_node_field_to[T](parent &Node, node TSNode, field_name string, text tree_sitter.SourceText) &T {
	field := field_opt(node, field_name) or { return &T{} }
	converted := convert_node(parent, field, text)
	if converted is T {
		return converted
	}
	return &T{}
}

pub fn convert_node(parent &Node, node TSNode, text tree_sitter.SourceText) Node {
	match node.type_name {
		.import_list {
			return convert_import_list(parent, node, text)
		}
		.identifier {
			return convert_identifier(parent, node, text)
		}
		.reference_expression {
			return convert_reference_expression(parent, node, text)
		}
		.type_identifier {
			return convert_type_identifier(parent, node, text)
		}
		.builtin_type {
			return convert_builtin_type(parent, node, text)
		}
		.type_initializer {
			return convert_type_initializer(parent, node, text)
		}
		.literal_value {
			return convert_literal_value(parent, node, text)
		}
		.field_name {
			return convert_field_name(parent, node, text)
		}
		.element_list {
			return convert_element_list(parent, node, text)
		}
		.short_element_list {
			return convert_short_element_list(parent, node, text)
		}
		.element {
			return convert_element(parent, node, text)
		}
		.block {
			return convert_block(parent, node, text)
		}
		.expression_list {
			return convert_expression_list(parent, node, text)
		}
		.call_expression {
			return convert_call_expression(parent, node, text)
		}
		.interpreted_string_literal {
			return convert_string_literal(parent, node, text)
		}
		.literal {
			return convert_literal(parent, node, text)
		}
		.var_declaration {
			return convert_var_declaration(parent, node, text)
		}
		.function_declaration {
			return convert_function_declaration(parent, node, text)
		}
		.signature {
			return convert_signature(parent, node, text)
		}
		.parameter_declaration {
			return convert_parameter_declaration(parent, node, text)
		}
		.parameter_list {
			return convert_parameter_list(parent, node, text)
		}
		.struct_declaration {
			return convert_struct_declaration(parent, node, text)
		}
		.module_clause {
			return convert_module_clause(parent, node, text)
		}
		.if_expression {
			return convert_if_expression(parent, node, text)
		}
		.return_statement {
			return convert_return_statement(parent, node, text)
		}
		.simple_statement {
			return convert_simple_statement(parent, node, text)
		}
		else {
			return null_node
		}
	}
}

fn field_or_none(node TSNode, name string) ?TSNode {
	return node.child_by_field_name(name) or { return none }
}

fn field(node TSNode, name string) TSNode {
	return node.child_by_field_name(name) or { panic(err) }
}

fn field_opt(node TSNode, name string) !tree_sitter.Node[v.NodeType] {
	return node.child_by_field_name(name)
}

fn field_id(node TSNode, id u32) TSNode {
	return node.child(id) or { panic(err) }
}

fn has_field(node TSNode, name string) bool {
	node.child_by_field_name(name) or { return false }
	return true
}

fn map_child[T, U](n tree_sitter.Node[T], cb fn (n tree_sitter.Node[T]) ?U) []U {
	mut result := []U{}
	for i := u32(0); i < n.child_count(); i++ {
		result << cb(n.child(i) or { panic("can't find #${i} node") }) or { continue }
	}
	return result
}

fn convert_identifier(parent &Node, node TSNode, text tree_sitter.SourceText) Identifier {
	return Identifier{
		id: counter++
		node: node
		value: node.text(text)
		parent: parent
	}
}

// Expressions

fn convert_reference_expression(parent &Node, node TSNode, text tree_sitter.SourceText) ReferenceExpression {
	return ReferenceExpression{
		id: counter++
		node: node
		identifier: convert_identifier(parent, field_id(node, 0), text)
		parent: parent
	}
}

fn convert_type_initializer(parent &Node, node TSNode, text tree_sitter.SourceText) TypeInitializer {
	return TypeInitializer{
		id: counter++
		node: node
		typ: convert_node_field(parent, node, 'type', text)
		value: convert_node_field_to[LiteralValue](parent, node, 'body', text)
		parent: parent
	}
}

fn convert_literal_value(parent &Node, node TSNode, text tree_sitter.SourceText) LiteralValue {
	return LiteralValue{
		id: counter++
		node: node
		element_list: convert_node_field_to[ElementList](parent, node, 'element_list',
			text)
		short_element_list: convert_node_field_to[ShortElementList](parent, node, 'short_element_list',
			text)
		parent: parent
	}
}

fn convert_element_list(parent &Node, node TSNode, text tree_sitter.SourceText) ElementList {
	mut elements := []Element{}
	mut sibling := node.child(0) or { return ElementList{} }
	for {
		if sibling.type_name == .keyed_element {
			elements << convert_element(parent, sibling, text)
		}
		sibling = sibling.next_sibling() or { break }
	}
	return ElementList{
		id: counter++
		node: node
		elements: elements
		parent: parent
	}
}

fn convert_short_element_list(parent &Node, node TSNode, text tree_sitter.SourceText) ShortElementList {
	mut elements := []Node{}
	mut sibling := node.child(0) or { return ShortElementList{} }
	for {
		if sibling.type_name == .element {
			elements << convert_node(parent, field_id(sibling, 0), text)
		}
		sibling = sibling.next_sibling() or { break }
	}
	return ShortElementList{
		id: counter++
		node: node
		elements: elements
		parent: parent
	}
}

fn convert_element(parent &Node, node TSNode, text tree_sitter.SourceText) Element {
	return Element{
		id: counter++
		node: node
		key: convert_node_field_to[FieldName](parent, node, 'key', text)
		value: convert_node_field(parent, node, 'value', text)
		parent: parent
	}
}

fn convert_field_name(parent &Node, node TSNode, text tree_sitter.SourceText) FieldName {
	return FieldName{
		id: counter++
		node: node
		expr: convert_node(parent, field_id(node, 0), text)
		parent: parent
	}
}

fn convert_expression_list(parent &Node, node TSNode, text tree_sitter.SourceText) ExpressionList {
	mut expressions := []Node{}
	mut sibling := node.child(0) or { return ExpressionList{} }
	for {
		if sibling.is_named() {
			expressions << convert_node(parent, sibling, text)
		}
		sibling = sibling.next_sibling() or { break }
	}
	return ExpressionList{
		id: counter++
		node: node
		expressions: expressions
		parent: parent
	}
}

fn convert_if_expression(parent &Node, node TSNode, text tree_sitter.SourceText) IfExpression {
	return IfExpression{
		id: counter++
		node: node
		condition: convert_node_field(parent, node, 'condition', text)
		guard: convert_node_field(parent, node, 'guard', text)
		block: convert_node_field(parent, node, 'block', text)
		else_branch: convert_node_field(parent, node, 'else_branch', text)
		parent: parent
	}
}

// Declarations

fn convert_var_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) VarDeclaration {
	return VarDeclaration{
		id: counter++
		node: node
		var_list: convert_node_field_to[ExpressionList](parent, node, 'var_list', text)
		expression_list: convert_node_field_to[ExpressionList](parent, node, 'expression_list',
			text)
		parent: parent
	}
}

pub fn convert_function_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) FunctionDeclaration {
	return FunctionDeclaration{
		id: counter++
		node: node
		name: convert_node_field_to[Identifier](parent, node, 'name', text)
		signature: convert_node_field_to[Signature](parent, node, 'signature', text)
		block: convert_node_field_to[Block](parent, node, 'body', text)
		parent: parent
	}
}

fn convert_signature(parent &Node, node TSNode, text tree_sitter.SourceText) Signature {
	return Signature{
		id: counter++
		node: node
		parameters: convert_node_field_to[ParameterList](parent, node, 'parameters', text)
		result: convert_node_field(parent, node, 'result', text)
		parent: parent
	}
}

fn convert_parameter_list(parent &Node, node TSNode, text tree_sitter.SourceText) ParameterList {
	parameters := map_child[v.NodeType, ParameterDeclaration](node, fn [text, parent] (n TSNode) ?ParameterDeclaration {
		if n.type_name == .parameter_declaration {
			return convert_parameter_declaration(parent, n, text)
		}

		return none
	})

	return ParameterList{
		id: counter++
		node: node
		parameters: parameters
		parent: parent
	}
}

fn convert_parameter_declaration(parent &Node, node TSNode, text tree_sitter.SourceText) ParameterDeclaration {
	// for i := u32(0); i < node.child_count(); i++ {
	// 	child := node.child(i) or { continue }
	// 	child.type_name == .triple_dot
	// }
	return ParameterDeclaration{
		id: counter++
		node: node
		name: convert_identifier(parent, field(node, 'name'), text)
		typ: convert_type(parent, field(node, 'type'), text)
		is_variadic: has_field(node, 'is_variadic')
		parent: parent
	}
}

fn convert_block(parent &Node, node TSNode, text tree_sitter.SourceText) Block {
	mut stmts := []Node{}
	for i := u32(0); i < node.child_count(); i++ {
		child := node.child(i) or { panic("can't find #${i} node") }
		if !child.is_named() {
			continue
		}
		stmts << convert_stmt(parent, child, text) or { continue }
	}

	return Block{
		id: counter++
		node: node
		stmts: stmts
		parent: parent
	}
}

fn convert_stmt(parent &Node, node TSNode, text tree_sitter.SourceText) ?Node {
	match node.type_name {
		.simple_statement {
			return convert_simple_statement(parent, node, text)
		}
		.assert_statement {}
		else {
			return convert_node(parent, node, text)
		}
	}

	return none
}

// Statements

fn convert_return_statement(parent &Node, node TSNode, text tree_sitter.SourceText) ReturnStatement {
	return ReturnStatement{
		id: counter++
		node: node
		expression_list: convert_node_field_to[ExpressionList](parent, node, 'expression_list',
			text)
		parent: parent
	}
}

fn convert_simple_statement(parent &Node, node TSNode, text tree_sitter.SourceText) SimplaStatement {
	return SimplaStatement{
		id: counter++
		node: node
		inner: convert_node(parent, node.child(0) or { panic(err) }, text)
		parent: parent
	}
}

fn convert_call_expression(parent &Node, node TSNode, text tree_sitter.SourceText) CallExpr {
	name := convert_identifier(parent, field(node, 'name'), text)
	args := convert_argument_list(parent, field(node, 'arguments'), text)

	return CallExpr{
		id: counter++
		node: node
		name: name
		args: args
		parent: parent
	}
}

fn convert_argument_list(parent &Node, node TSNode, text tree_sitter.SourceText) ArgumentList {
	args := map_child[v.NodeType, Argument](node, fn [text, parent] (n TSNode) ?Argument {
		if !n.is_named() {
			return none
		}

		return convert_argument(parent, n, text)
	})

	return ArgumentList{
		id: counter++
		node: node
		args: args
		parent: parent
	}
}

fn convert_argument(parent &Node, node TSNode, text tree_sitter.SourceText) Argument {
	return Argument{
		id: counter++
		node: node
		expr: convert_node(parent, node, text)
		parent: parent
	}
}

fn convert_type_identifier(parent &Node, node TSNode, text tree_sitter.SourceText) TypeName {
	return TypeName{
		id: counter++
		node: node
		name: convert_identifier(parent, node, text)
		parent: parent
	}
}

fn convert_type(parent &Node, node TSNode, text tree_sitter.SourceText) Type {
	match node.type_name {
		.builtin_type {
			return convert_builtin_type(parent, node, text)
		}
		else {
			return SimpleType{
				id: counter++
				node: node
				name: Identifier{} // TODO
				parent: parent
			}
			// panic("can't convert type ${node.type_name}")
		}
	}
}

fn convert_builtin_type(parent &Node, node TSNode, text tree_sitter.SourceText) BuiltinType {
	return BuiltinType{
		id: counter++
		node: node
		name: node.text(text)
		parent: parent
	}
}

fn convert_string_literal(parent &Node, node TSNode, text tree_sitter.SourceText) StringLiteral {
	return StringLiteral{
		id: counter++
		node: node
		text: node.text(text)
		parent: parent
	}
}

fn convert_int_literal(parent &Node, node TSNode, text tree_sitter.SourceText) IntegerLiteral {
	return IntegerLiteral{
		id: counter++
		node: node
		value: node.text(text)
		parent: parent
	}
}

fn convert_boolean_literal(parent &Node, node TSNode, text tree_sitter.SourceText) BooleanLiteral {
	return BooleanLiteral{
		id: counter++
		node: node
		value: node.text(text).bool()
		parent: parent
	}
}

fn convert_none_literal(parent &Node, node TSNode, text tree_sitter.SourceText) NoneLiteral {
	return NoneLiteral{
		id: counter++
		node: node
		parent: parent
	}
}

fn convert_literal(parent &Node, node TSNode, text tree_sitter.SourceText) Node {
	inner := field_id(node, 0)
	match inner.type_name {
		.interpreted_string_literal {
			return convert_string_literal(parent, node, text)
		}
		.int_literal {
			return convert_int_literal(parent, node, text)
		}
		.true_, .false_ {
			return convert_boolean_literal(parent, node, text)
		}
		.none_ {
			return convert_none_literal(parent, node, text)
		}
		else {
			return null_node
		}
	}
}
