module analyzer

import analyzer.index
import analyzer.psi

pub struct Resolver {
	indexer &Indexer
}

pub fn (r &Resolver) resolve_local(file OpenedFile, element psi.ReferenceExpression) ?psi.PsiElement {
	return element.resolve_local(file.psi_file)
}

pub fn (r &Resolver) resolve(file OpenedFile, element psi.ReferenceExpression) ?ResolveResult {
	res := element.resolve_local(file.psi_file) or { return none }
	return new_resolve_result(file.psi_file, res)
}

struct ResolveResult {
pub:
	filepath string
	name     string
	pos      index.Pos
}

fn new_resolve_result(containing_file psi.PsiFileImpl, element psi.PsiElement) ResolveResult {
	return ResolveResult{
		filepath: containing_file.path()
		name: if element is psi.PsiNamedElement { element.name() } else { '' }
		pos: index.Pos{
			line: int(element.node.start_point().row)
			column: int(element.node.start_point().column)
			end_line: int(element.node.end_point().row)
			end_column: int(element.node.end_point().column)
		}
	}
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
