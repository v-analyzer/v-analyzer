module analyzer

import analyzer.index
import analyzer.psi

pub struct Resolver {
	indexer &Indexer
}

pub fn (r &Resolver) resolve(file OpenedFile, el psi.ReferenceExpression) ?index.CachedNamedSymbol {
	identifier := el.identifier()?
	name := identifier.get_text()
	fqn := file.fqn(name)

	if data := r.find_function(fqn) {
		return data
	}

	if struct_data := r.find_struct(fqn) {
		return struct_data
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
