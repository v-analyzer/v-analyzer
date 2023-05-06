module psi

pub struct Block {
	PsiElementImpl
}

pub fn (b Block) process_declarations(mut processor PsiScopeProcessor) bool {
	statements := b.find_children_by_type(.simple_statement)
	for statement in statements {
		first_child := statement.first_child() or { continue }

		if first_child is VarDeclaration {
			for var in first_child.vars() {
				if !processor.execute(var) {
					return false
				}
			}
		}
	}
	return true
}
