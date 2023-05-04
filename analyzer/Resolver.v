module analyzer

import analyzer.ir
import analyzer.indexer

pub struct Resolver {
	index &indexer.Indexer
}

pub fn (r &Resolver) resolve(file OpenedFile, el ir.ReferenceExpression) ?indexer.CachedNamedSymbol {
	name := el.identifier.value
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
	index := r.index.index.data
	for _, datum in index.data {
		for func in datum.functions {
			if func.name == name {
				return func
			}
		}
	}
	return none
}

pub fn (r &Resolver) find_struct(name string) ?indexer.StructCache {
	index := r.index.index.data
	for _, datum in index.data {
		for struct_ in datum.structs {
			if struct_.name == name {
				return struct_
			}
		}
	}
	return none
}
