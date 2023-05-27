module completion

import analyzer.psi
import lsp

pub struct CompletionContext {
pub:
	element      psi.PsiElement
	position     lsp.Position
	offset       u64
	trigger_kind lsp.CompletionTriggerKind
}
