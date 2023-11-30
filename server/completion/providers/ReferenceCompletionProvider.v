module providers

import analyzer.psi
import analyzer.lang
import server.completion
import analyzer.psi.types

pub struct ReferenceCompletionProvider {
pub mut:
	processor &ReferenceCompletionProcessor
}

fn (_ &ReferenceCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_expression || ctx.is_type_reference
}

fn (mut r ReferenceCompletionProvider) add_completion(ctx &completion.CompletionContext, mut _ completion.CompletionResultSet) {
	element := ctx.element
	text := element.get_text()
	if text.starts_with('@') {
		// See `CompileTimeConstantCompletionProvider`
		return
	}

	parent := element.parent() or { return }
	containing_file := parent.containing_file

	if parent is psi.ReferenceExpressionBase {
		sub := psi.SubResolver{
			containing_file: containing_file
			element: parent
			for_types: parent is psi.TypeReferenceExpression
		}

		variants := StructLiteralCompletion{}.allowed_variants(ctx, parent)
		field_initializers := StructLiteralCompletion{}.get_field_initializers(element)
		already_assigned := StructLiteralCompletion{}.already_assigned_fields(field_initializers)

		if variants != .none_ {
			r.process_fields(ctx, parent as psi.PsiElement, already_assigned)
		}

		if variants != .field_name_only {
			sub.process_resolve_variants(mut r.processor)
		}
	}
}

fn (mut r ReferenceCompletionProvider) process_fields(ctx &completion.CompletionContext, element psi.PsiElement, already_assigned []string) {
	grand := element.parent() or { return }
	if grand.node.type_name != .element_list {
		return
	}

	type_initializer := grand.parent_nth(2) or { return }

	if type_initializer is psi.TypeInitializer {
		typ := type_initializer.get_type()

		qualified_name := if typ is types.ArrayType {
			'stubs.ArrayInit'
		} else if typ is types.ChannelType {
			'stubs.ChanInit'
		} else {
			typ.qualified_name()
		}

		if struct_ := psi.find_struct(qualified_name) {
			for field in struct_.fields() {
				if field is psi.StructFieldDeclaration {
					if !field.is_public() && !lang.is_same_module(ctx.element, *field) {
						continue
					}

					if field.name() in already_assigned {
						continue
					}

					r.processor.execute(field)
				}
			}
		}

		if interface_ := psi.find_interface(qualified_name) {
			for field in interface_.fields() {
				if field is psi.InterfaceFieldDeclaration {
					if !lang.is_same_module(ctx.element, *field) {
						continue
					}

					if field.name() in already_assigned {
						continue
					}

					r.processor.execute(field)
				}
			}
		}
	}
}
