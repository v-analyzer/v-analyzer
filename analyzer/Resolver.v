module analyzer

import analyzer.indexer
import analyzer.psi

pub struct Resolver {
	index &indexer.Indexer
}

pub fn (r &Resolver) resolve(file OpenedFile, el psi.ReferenceExpression) ?indexer.CachedNamedSymbol {
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

pub fn (r &Resolver) find_function(name string) ?indexer.FunctionCache {
	for indexing_root in r.index.roots {
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

pub fn (r &Resolver) find_struct(name string) ?indexer.StructCache {
	for indexing_root in r.index.roots {
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
