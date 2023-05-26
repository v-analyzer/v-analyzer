module psi

import analyzer.psi.types

pub struct TypeInferer {
}

pub fn (t &TypeInferer) infer_type(elem ?PsiElement) types.Type {
	element := elem or { return types.unknown_type }
	if element.node.type_name in [.in_expression, .not_in_expression, .is_expression,
		.not_is_expression] {
		return types.new_primitive_type('bool')
	}

	if element.node.type_name == .binary_expression {
		operator_element := element.find_child_by_name('operator') or { return types.unknown_type }
		operator := operator_element.get_text()
		if operator in ['&&', '||', '==', '!=', '<', '<=', '>', '>='] {
			return types.new_primitive_type('bool')
		}

		match operator {
			'<<' { return types.new_primitive_type('int') }
			'>>' { return types.new_primitive_type('int') }
			else {}
		}

		if operator in ['+', '-', '|', '^'] {
			left := element.first_child() or { return types.unknown_type }
			return t.infer_type(left)
		}

		if operator == '*' {
			left := element.first_child() or { return types.unknown_type }
			if left.node.type_name != .literal {
				return t.infer_type(left)
			}
			right := element.last_child() or { return types.unknown_type }
			return t.infer_type(right)
		}
	}

	if element.node.type_name == .select_expression {
		return types.new_primitive_type('bool')
	}

	if element.node.type_name == .unary_expression {
		operator_element := element.find_child_by_name('operator') or { return types.unknown_type }
		operator := operator_element.get_text()
		if operator == '!' {
			return types.new_primitive_type('bool')
		}

		expression := element.find_child_by_name('operand') or { return types.unknown_type }
		expr_type := t.infer_type(expression)

		match operator {
			'&' { return types.new_pointer_type(expr_type) }
			'*' { return types.unwrap_pointer_type(expr_type) }
			'<-' { return types.unwrap_channel_type(expr_type) }
			else { return expr_type }
		}
	}

	if element.node.type_name == .inc_statement || element.node.type_name == .dec_statement {
		return t.infer_type(element.first_child())
	}

	if element.node.type_name == .as_type_cast_expression {
		return t.infer_type(element.last_child())
	}

	if element.node.type_name in [.spawn_expression, .go_expression] {
		return types.new_thread_type(t.infer_type(element.last_child()))
	}

	if element.node.type_name == .parenthesized_expression {
		expr := element.find_child_by_name('expression') or { return types.unknown_type }
		return t.infer_type(expr)
	}

	if element is IndexExpression {
		expr := element.expression() or { return types.unknown_type }
		expr_type := t.infer_type(expr)
		return t.infer_index_type(expr_type)
	}

	if element is SliceExpression {
		expr := element.expression() or { return types.unknown_type }
		expr_type := t.infer_type(expr)
		if expr_type is types.FixedArrayType {
			// [3]int -> []int
			return types.new_array_type(expr_type.inner)
		}
		return expr_type
	}

	if element is Range {
		if element.inclusive() {
			left := element.left() or { return types.unknown_type }
			return t.infer_type(left)
		}

		return types.new_array_type(types.new_primitive_type('int'))
	}

	if element is FunctionLiteral {
		signature := element.signature() or { return types.unknown_type }
		return t.process_signature(signature)
	}

	if element is ReferenceExpression {
		resolved := element.resolve() or { return types.unknown_type }
		return t.infer_type(resolved)
	}

	if element is TypeInitializer {
		type_element := element.find_child_by_type(.plain_type) or { return types.unknown_type }
		return t.convert_type(type_element)
	}

	if element is UnsafeExpression {
		block := element.block()
		return t.infer_type(block)
	}

	if element is IfExpression {
		block := element.block()
		block_type := t.infer_type(block)
		if block_type is types.UnknownType {
			else_branch := element.else_branch() or { return types.unknown_type }
			return t.infer_type(else_branch)
		}
		return block_type
	}

	if element is CompileTimeIfExpression {
		block := element.block()
		block_type := t.infer_type(block)
		if block_type is types.UnknownType {
			else_branch := element.else_branch() or { return types.unknown_type }
			return t.infer_type(else_branch)
		}
		return block_type
	}

	if element is MatchExpression {
		arms := element.arms()
		if arms.len == 0 {
			return types.unknown_type
		}
		first := arms.first()
		block := first.find_child_by_name('block') or { return types.unknown_type }
		return t.infer_type(block)
	}

	if element is ArrayCreation {
		expressions := element.expressions()
		if expressions.len == 0 {
			return types.new_array_type(types.unknown_type)
		}
		first_expr := expressions.first()

		if element.is_fixed {
			return types.new_fixed_array_type(t.infer_type(first_expr), expressions.len)
		}

		return types.new_array_type(t.infer_type(first_expr))
	}

	if element is MapInitExpression {
		key_values := element.key_values()
		if key_values.len == 0 {
			return types.new_map_type(types.unknown_type, types.unknown_type)
		}

		first_key_value := key_values.first()
		if first_key_value is MapKeyedElement {
			key := first_key_value.key() or { return types.unknown_type }
			value := first_key_value.value() or { return types.unknown_type }
			key_type := t.infer_type(key)
			value_type := t.infer_type(value)
			return types.new_map_type(key_type, value_type)
		}

		return types.new_map_type(types.unknown_type, types.unknown_type)
	}

	if element is CallExpression {
		return t.infer_call_expr_type(element)
	}

	if element is Literal {
		return t.infer_literal_type(element)
	}

	if element is ParameterDeclaration {
		return element.get_type()
	}

	if element is Signature {
		return t.process_signature(element)
	}

	if element is VarDefinition {
		parent := element.parent_nth(2) or { return types.unknown_type }
		if parent.node.type_name == .range_clause {
			return t.process_range_clause(element, parent)
		}

		decl := element.declaration() or { return types.unknown_type }
		if init := decl.initializer_of(element) {
			return t.infer_type(init)
		}
		return types.unknown_type
	}

	if element is ConstantDefinition {
		return element.get_type()
	}

	if element is Block {
		last_expression := element.last_expression() or { return types.unknown_type }
		return t.infer_type(last_expression)
	}

	if element is FunctionOrMethodDeclaration {
		signature := element.signature() or { return types.unknown_type }
		return t.process_signature(signature)
	}

	return types.unknown_type
}

pub fn (t &TypeInferer) process_signature(signature Signature) types.Type {
	params := signature.parameters()
	param_types := params.map(fn [t] (it PsiElement) types.Type {
		// TODO: support fn (int, string) without names
		if it is PsiTypedElement {
			return it.get_type()
		}
		return types.unknown_type
	})
	result := signature.result()
	result_type := t.convert_type(result)
	return types.new_function_type(param_types, result_type, result == none)
}

pub fn (t &TypeInferer) process_range_clause(element PsiElement, range PsiElement) types.Type {
	right := range.find_child_by_name('right') or { return types.unknown_type }
	right_type := t.infer_type(right)
	var_definition_list := range.find_child_by_name('left') or { return types.unknown_type }
	var_definitions := var_definition_list.find_children_by_type(.var_definition)

	if var_definitions.len == 1 {
		if right_type is types.ArrayType {
			return right_type.inner
		}
		if right_type is types.FixedArrayType {
			return right_type.inner
		}
		if right_type is types.MapType {
			return right_type.value
		}
		if right_type is types.StringType {
			return types.new_primitive_type('u8')
		}
	}

	mut define_index := 0
	for index, def in var_definitions {
		if def.is_equal(element) {
			define_index = index
			break
		}
	}

	if define_index == 0 {
		if right_type is types.MapType {
			return right_type.key
		}
		return types.new_primitive_type('int')
	}

	if define_index == 1 {
		if right_type is types.ArrayType {
			return right_type.inner
		}
		if right_type is types.FixedArrayType {
			return right_type.inner
		}
		if right_type is types.MapType {
			return right_type.value
		}
		if right_type is types.StringType {
			return types.new_primitive_type('u8')
		}

		return types.unknown_type
	}

	return types.unknown_type
}

pub fn (t &TypeInferer) infer_call_expr_type(element CallExpression) types.Type {
	resolved := element.resolve() or { return types.unknown_type }
	typ := t.infer_type(resolved)
	if typ is types.FunctionType {
		return typ.result
	}

	return types.unknown_type
}

pub fn (_ &TypeInferer) infer_literal_type(element Literal) types.Type {
	child := element.first_child() or { return types.unknown_type }
	if child.node.type_name == .interpreted_string_literal
		|| child.node.type_name == .raw_string_literal {
		return types.string_type
	}

	if child.node.type_name == .c_string_literal {
		return types.new_pointer_type(types.new_primitive_type('u8'))
	}

	if child.node.type_name == .int_literal {
		return types.new_primitive_type('int')
	}

	if child.node.type_name == .float_literal {
		return types.new_primitive_type('f64')
	}

	if child.node.type_name == .rune_literal {
		return types.new_primitive_type('rune')
	}

	if child.node.type_name == .true_ || child.node.type_name == .false_ {
		return types.new_primitive_type('bool')
	}

	if child.node.type_name == .nil_ {
		return types.new_primitive_type('voidptr')
	}

	if child.node.type_name == .none_ {
		return types.new_primitive_type('none')
	}

	return types.unknown_type
}

pub fn (t &TypeInferer) infer_index_type(typ types.Type) types.Type {
	if typ is types.ArrayType {
		return typ.inner
	}
	if typ is types.MapType {
		return typ.value
	}
	if typ is types.PrimitiveType {
		if typ.name == 'string' {
			return types.new_primitive_type('u8')
		}

		return types.unknown_type
	}
	if typ is types.PointerType {
		return typ.inner
	}

	return types.unknown_type
}

pub fn (t &TypeInferer) infer_from_plain_type(element PsiElement) types.Type {
	if element.stub_id != non_stubbed_element {
		stub := element.stub_list().get_stub(element.stub_id) or { return types.unknown_type }
		type_stub := stub.get_child_by_type(.plain_type) or { return types.unknown_type }
		psi := type_stub.get_psi() or { return types.unknown_type }
		return t.convert_type(psi)
	}

	if plain_typ := element.find_child_by_type(.plain_type) {
		return t.convert_type(plain_typ)
	}

	return types.unknown_type
}

pub fn (t &TypeInferer) convert_type(plain_type ?PsiElement) types.Type {
	typ := plain_type or { return types.unknown_type }
	if plain_type !is PlainType {
		return types.unknown_type
	}

	child := typ.first_child_or_stub() or { return types.unknown_type }

	if child.element_type() == .pointer_type {
		inner := child.last_child_or_stub()
		return types.new_pointer_type(t.convert_type(inner))
	}

	if child.element_type() == .array_type {
		inner := child.last_child_or_stub()
		return types.new_array_type(t.convert_type(inner))
	}

	if child.element_type() == .fixed_array_type {
		// TODO: parse size
		inner := child.last_child_or_stub()
		return types.new_array_type(t.convert_type(inner))
	}

	if child.element_type() == .thread_type {
		inner := child.last_child_or_stub()
		return types.new_thread_type(t.convert_type(inner))
	}

	if child.element_type() == .channel_type {
		inner := child.last_child_or_stub()
		return types.new_channel_type(t.convert_type(inner))
	}

	if child.element_type() == .map_type {
		// TODO: stubs
		key := child.find_child_by_name('key')
		value := child.find_child_by_name('value')
		return types.new_map_type(t.convert_type(key), t.convert_type(value))
	}

	if child is TypeReferenceExpression {
		text := child.get_text()
		if types.is_primitive_type(text) {
			// fast path
			return types.new_primitive_type(text)
		}

		if text == 'string' {
			return types.string_type
		}

		resolved := child.resolve() or { return types.unknown_type }
		if resolved is StructDeclaration {
			return types.new_struct_type(resolved.name())
		}

		if resolved is EnumDeclaration {
			return types.new_enum_type(resolved.name())
		}

		return types.unknown_type
	}

	return types.unknown_type
}
