module psi

import utils

pub enum StubType as u8 {
	root
	function_declaration
	method_declaration
	receiver
	signature
	struct_declaration
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
	plain_type
}

pub struct StubbedElementType {}

pub fn (_ &StubbedElementType) index_stub(stub &StubBase, mut sink IndexSink) {
	if stub.stub_type == .function_declaration {
		sink.occurrence(StubIndexKey.functions, stub.name())
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
	if stub_type == .struct_declaration {
		return StructDeclaration{
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

	if psi is Receiver {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		return new_stub_base(parent_stub, .receiver, psi.name(), text_range,
			text: psi.get_text()
		)
	}

	if psi is Signature {
		return new_stub_base(parent_stub, .signature, '', psi.text_range(),
			text: psi.get_text()
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
			text: ''
			comment: comment
		)
	}

	if psi is EnumDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base(parent_stub, .enum_declaration, psi.name(), text_range,
			text: ''
			comment: comment
		)
	}

	if psi is EnumFieldDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base(parent_stub, .enum_field_definition, psi.name(), text_range,

			text: psi.get_text()
			comment: comment
		)
	}

	if psi is FieldDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base(parent_stub, .field_declaration, psi.name(), text_range,

			text: psi.get_text()
			comment: comment
		)
	}

	if psi is StructFieldScope {
		return new_stub_base(parent_stub, .struct_field_scope, '', psi.text_range(),
			text: psi.get_text()
		)
	}

	if psi is ConstantDefinition {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base(parent_stub, .constant_declaration, psi.name(), text_range,

			comment: comment
		)
	}

	if psi is TypeAliasDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base(parent_stub, .type_alias_declaration, psi.name(), text_range,

			comment: comment
		)
	}

	if psi is Attributes {
		return new_stub_base(parent_stub, .attributes, '', psi.text_range())
	}

	if psi is Attribute {
		return new_stub_base(parent_stub, .attribute, '', psi.text_range())
	}

	if psi is AttributeExpression {
		return new_stub_base(parent_stub, .attribute_expression, '', psi.text_range())
	}

	if psi is ValueAttribute {
		return new_stub_base(parent_stub, .value_attribute, '', psi.text_range(),
			text: psi.get_text()
		)
	}

	if psi is PlainType {
		return new_stub_base(parent_stub, .plain_type, '', psi.text_range(),
			text: psi.get_text()
		)
	}

	return none
}
