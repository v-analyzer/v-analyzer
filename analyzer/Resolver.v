module analyzer

import analyzer.index
import analyzer.psi

pub struct Resolver {
	indexer &Indexer
}

pub fn (r &Resolver) resolve_local(element psi.ReferenceExpressionBase) ?psi.PsiElement {
	return element.resolve_local()
}

struct ResolveResult {
pub:
	filepath string
	name     string
	pos      index.Pos
}

pub fn new_resolve_result(containing_file &psi.PsiFileImpl, element psi.PsiElement) ?ResolveResult {
	if element is psi.PsiNamedElement {
		identifier := element.identifier() or { return none }
		return ResolveResult{
			pos: index.Pos{
				line: int(identifier.node().start_point().row)
				column: int(identifier.node().start_point().column)
				end_line: int(identifier.node().end_point().row)
				end_column: int(identifier.node().end_point().column)
			}
			filepath: containing_file.path()
			name: element.name()
		}
	}

	return none
}

pub fn (r &Resolver) find_function(name string) ?index.FunctionCache {
	for indexing_root in r.indexer.roots {
		for _, datum in indexing_root.index.data.data {
			for func in datum.functions {
				if func.name == name {
					return func
				}
			}
		}
	}
	return none
}

pub fn (r &Resolver) find_struct(name string) ?index.StructCache {
	for indexing_root in r.indexer.roots {
		for _, datum in indexing_root.index.data.data {
			for struct_ in datum.structs {
				if struct_.name == name {
					return struct_
				}
			}
		}
	}
	return none
}
