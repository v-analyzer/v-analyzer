module completion

import analyzer.psi
import lsp

pub struct CompletionContext {
pub:
	element      psi.PsiElement
	position     lsp.Position
	offset       u64
	trigger_kind lsp.CompletionTriggerKind
pub mut:
	is_test_file        bool
	is_start_of_file    bool
	is_top_level        bool
	is_statement        bool
	is_expression       bool
	is_type_reference   bool
	is_import_name      bool
	is_attribute        bool
	is_assert_statement bool
	inside_loop         bool
}

pub fn (mut c CompletionContext) compute() {
	c.is_test_file = c.element.containing_file.is_test_file()

	line := c.element.text_range().line
	if line < 3 {
		c.is_start_of_file = true
	}

	parent := c.element.parent() or { return }

	if parent is psi.ImportName {
		c.is_import_name = true
	}

	if parent.node.type_name == .reference_expression {
		if grand := parent.parent() {
			// не считаем выражением reference_expression если он внутри атрибута
			c.is_expression = grand !is psi.ValueAttribute
		}
	}

	if parent.node.type_name == .type_reference_expression {
		c.is_type_reference = true
	}

	if parent.node.type_name == .for_statement {
		c.inside_loop = true
	}

	if grand := parent.parent() {
		if grand.node.type_name == .simple_statement {
			c.is_statement = true
		}
		if grand.node.type_name == .assert_statement {
			c.is_assert_statement = true
		}
		if grand.node.type_name == .value_attribute {
			c.is_attribute = true
		}

		if grand.node.type_name == .for_statement {
			c.inside_loop = true
		}

		if grand_grand := grand.parent() {
			if grand_grand.node.type_name == .source_file {
				c.is_top_level = true
			}

			if grand_grand.node.type_name == .for_statement {
				c.inside_loop = true
			}
		}
	}

	if !c.inside_loop {
		// долгий путь в случае если первые три родителя вверх не являются циклами
		c.inside_loop = c.element.inside(.for_statement)
	}
}
