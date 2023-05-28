module psi

import utils
import tree_sitter_v

pub enum StubType as u8 {
	root
	function_declaration
	method_declaration
	receiver
	signature
	parameter_list
	parameter_declaration
	struct_declaration
	interface_declaration
	interface_method_declaration
	enum_declaration
	field_declaration
	struct_field_scope
	enum_field_definition
	constant_declaration
	type_alias_declaration
	attributes
	attribute
	attribute_expression
	value_attribute
	// types
	plain_type
	type_reference_expression
	qualified_type
	pointer_type
	wrong_pointer_type
	array_type
	fixed_array_type
	function_type
	generic_type
	map_type
	channel_type
	shared_type
	thread_type
	multi_return_type
	option_type
	result_type
	//
	visibility_modifiers
	import_list
	import_declaration
	import_spec
	import_path
	import_name
	import_alias
	module_clause
}

pub fn node_type_to_stub_type(typ tree_sitter_v.NodeType) StubType {
	return match typ {
		.function_declaration { .function_declaration }
		.receiver { .receiver }
		.signature { .signature }
		.parameter_list { .parameter_list }
		.parameter_declaration { .parameter_declaration }
		.struct_declaration { .struct_declaration }
		.interface_declaration { .interface_declaration }
		.interface_method_definition { .interface_method_declaration }
		.struct_field_declaration { .field_declaration }
		.const_definition { .constant_declaration }
		.type_declaration { .type_alias_declaration }
		.enum_declaration { .enum_declaration }
		.enum_field_definition { .enum_field_definition }
		.struct_field_scope { .struct_field_scope }
		.attributes { .attributes }
		.attribute { .attribute }
		.attribute_expression { .attribute_expression }
		.value_attribute { .value_attribute }
		// types
		.plain_type { .plain_type }
		.type_reference_expression { .type_reference_expression }
		.qualified_type { .qualified_type }
		.pointer_type { .pointer_type }
		.wrong_pointer_type { .wrong_pointer_type }
		.array_type { .array_type }
		.fixed_array_type { .fixed_array_type }
		.function_type { .function_type }
		.generic_type { .generic_type }
		.map_type { .map_type }
		.channel_type { .channel_type }
		.shared_type { .shared_type }
		.thread_type { .thread_type }
		.multi_return_type { .multi_return_type }
		.option_type { .option_type }
		.result_type { .result_type }
		// types end
		.visibility_modifiers { .visibility_modifiers }
		.import_list { .import_list }
		.import_declaration { .import_declaration }
		.import_spec { .import_spec }
		.import_path { .import_path }
		.import_name { .import_name }
		.import_alias { .import_alias }
		.module_clause { .module_clause }
		else { .root }
	}
}

pub struct StubbedElementType {}

pub fn (_ &StubbedElementType) index_stub(stub &StubBase, mut sink IndexSink) {
	if stub.stub_type == .function_declaration {
		name := stub.name()
		if name == 'main' || name.starts_with('test_') {
			return
		}

		sink.occurrence(StubIndexKey.functions, name)
	}

	if stub.stub_type == .method_declaration {
		receiver := stub.receiver()
		sink.occurrence(StubIndexKey.methods, receiver)
	}

	if stub.stub_type == .struct_declaration {
		name := stub.name()
		if name.ends_with('Attribute') {
			// convert DeprecatedAfter to deprecated_after
			clear_name := utils.pascal_case_to_snake_case(name.trim_string_right('Attribute'))
			sink.occurrence(StubIndexKey.attributes, clear_name)
			return
		}

		sink.occurrence(StubIndexKey.structs, name)
	}

	if stub.stub_type == .interface_declaration {
		sink.occurrence(StubIndexKey.interfaces, stub.name())
	}

	if stub.stub_type == .enum_declaration {
		sink.occurrence(StubIndexKey.enums, stub.name())
	}

	if stub.stub_type == .constant_declaration {
		sink.occurrence(StubIndexKey.constants, stub.name())
	}

	if stub.stub_type == .type_alias_declaration {
		sink.occurrence(StubIndexKey.type_aliases, stub.name())
	}
}

pub fn (_ &StubbedElementType) create_psi(stub &StubBase) ?PsiElement {
	stub_type := stub.stub_type()
	base_psi := new_psi_node_from_stub(stub.id, stub.stub_list)

	if stub_type == .function_declaration || stub_type == .method_declaration {
		return FunctionOrMethodDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .receiver {
		return Receiver{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .signature {
		return Signature{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .parameter_list {
		return ParameterList{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .parameter_declaration {
		return ParameterDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .type_reference_expression {
		return TypeReferenceExpression{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .struct_declaration {
		return StructDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .interface_declaration {
		return InterfaceDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .interface_method_declaration {
		return InterfaceMethodDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .enum_declaration {
		return EnumDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .enum_field_definition {
		return EnumFieldDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .field_declaration {
		return FieldDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .struct_field_scope {
		return StructFieldScope{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .constant_declaration {
		return ConstantDefinition{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .type_alias_declaration {
		return TypeAliasDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .attributes {
		return Attributes{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .attribute {
		return Attribute{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .attribute_expression {
		return AttributeExpression{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .value_attribute {
		return ValueAttribute{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .plain_type {
		return PlainType{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .qualified_type {
		return QualifiedType{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .visibility_modifiers {
		return VisibilityModifiers{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .import_list {
		return ImportList{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .import_declaration {
		return ImportDeclaration{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .import_spec {
		return ImportSpec{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .import_path {
		return ImportPath{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .import_alias {
		return ImportAlias{
			PsiElementImpl: base_psi
		}
	}
	if stub_type == .module_clause {
		return ModuleClause{
			PsiElementImpl: base_psi
		}
	}
	return base_psi
}

pub fn (_ &StubbedElementType) get_receiver_type(psi FunctionOrMethodDeclaration) string {
	receiver := psi.receiver() or { return '' }
	typ := receiver.type_element() or { return '' }
	text := typ.get_text()
	return text.trim_string_left('&')
}

pub fn (s &StubbedElementType) create_stub(psi PsiElement, parent_stub &StubElement) ?&StubBase {
	if psi is FunctionOrMethodDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()

		receiver_type := s.get_receiver_type(psi)
		is_method := receiver_type != ''
		stub_type := if is_method {
			StubType.method_declaration
		} else {
			StubType.function_declaration
		}
		return new_stub_base(parent_stub, stub_type, psi.name(), text_range,
			comment: comment
			receiver: receiver_type
		)
	}

	if psi is StructDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		name := if psi.is_attribute() {
			psi.name() + 'Attribute'
		} else {
			psi.name()
		}
		return new_stub_base(parent_stub, .struct_declaration, name, text_range,
			comment: comment
		)
	}

	if psi is InterfaceDeclaration {
		return declaration_stub(*psi, parent_stub, .interface_declaration)
	}

	if psi is InterfaceMethodDeclaration {
		return declaration_stub(*psi, parent_stub, .interface_method_declaration)
	}

	if psi is Receiver {
		return declaration_stub(*psi, parent_stub, .receiver, include_text: true)
	}

	if psi is Signature {
		return text_based_stub(*psi, parent_stub, .signature)
	}

	if psi is ParameterList {
		return text_based_stub(*psi, parent_stub, .parameter_list)
	}

	if psi is ParameterDeclaration {
		return declaration_stub(*psi, parent_stub, .parameter_declaration, include_text: true)
	}

	if psi is EnumDeclaration {
		return declaration_stub(*psi, parent_stub, .enum_declaration)
	}

	if psi is EnumFieldDeclaration {
		return declaration_stub(*psi, parent_stub, .enum_field_definition)
	}

	if psi is FieldDeclaration {
		return declaration_stub(*psi, parent_stub, .field_declaration)
	}

	if psi is ConstantDefinition {
		return declaration_stub(*psi, parent_stub, .constant_declaration)
	}

	if psi is TypeAliasDeclaration {
		return declaration_stub(*psi, parent_stub, .type_alias_declaration)
	}

	if psi is StructFieldScope {
		return text_based_stub(*psi, parent_stub, .struct_field_scope)
	}

	if psi is Attributes {
		return new_stub_base(parent_stub, .attributes, '', psi.text_range())
	}

	if psi is Attribute {
		return text_based_stub(*psi, parent_stub, .attribute)
	}

	if psi is AttributeExpression {
		return text_based_stub(*psi, parent_stub, .attribute_expression)
	}

	if psi is ValueAttribute {
		return text_based_stub(*psi, parent_stub, .value_attribute)
	}

	if psi is VisibilityModifiers {
		return text_based_stub(*psi, parent_stub, .visibility_modifiers)
	}

	if psi is ModuleClause {
		return declaration_stub(*psi, parent_stub, .module_clause)
	}

	if node_is_type(psi) {
		stub_type := node_type_to_stub_type(psi.node.type_name)
		return text_based_stub(psi, parent_stub, stub_type)
	}

	if psi is ImportSpec {
		return declaration_stub(*psi, parent_stub, .import_spec, include_text: true)
	}

	if psi.node.type_name in [.import_list, .import_declaration, .import_path, .import_name,
		.import_alias] {
		stub_type := node_type_to_stub_type(psi.node.type_name)
		return text_based_stub(psi, parent_stub, stub_type,
			include_text: psi.node.type_name !in [
				.import_list,
				.import_declaration,
			]
		)
	}

	return none
}

[params]
struct StubParams {
	include_text bool
}

[inline]
pub fn declaration_stub(psi PsiNamedElement, parent_stub &StubElement, stub_type StubType, params StubParams) ?&StubBase {
	text_range := if identifier := psi.identifier() {
		identifier.text_range()
	} else {
		(psi as PsiElement).text_range()
	}
	return new_stub_base(parent_stub, stub_type, psi.name(), text_range,
		comment: if psi is PsiDocCommentOwner { psi.doc_comment() } else { '' }
		text: if params.include_text { (psi as PsiElement).get_text() } else { '' }
	)
}

[params]
struct TestStubParams {
	include_text bool = true
}

[inline]
pub fn text_based_stub(psi PsiElement, parent_stub &StubElement, stub_type StubType, params TestStubParams) ?&StubBase {
	return new_stub_base(parent_stub, stub_type, '', psi.text_range(),
		text: if params.include_text { psi.get_text() } else { '' }
	)
}

[inline]
pub fn node_is_type(psi PsiElement) bool {
	return psi.node.type_name in [
		.plain_type,
		.type_reference_expression,
		.qualified_type,
		.pointer_type,
		.wrong_pointer_type,
		.array_type,
		.fixed_array_type,
		.function_type,
		.generic_type,
		.map_type,
		.channel_type,
		.shared_type,
		.thread_type,
		.multi_return_type,
		.option_type,
		.result_type,
	]
}
