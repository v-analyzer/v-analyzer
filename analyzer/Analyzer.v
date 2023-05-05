module analyzer

pub struct Analyzer {
pub mut:
	index    &Indexer
	resolver Resolver
}

pub fn new() &Analyzer {
	indexer := new_indexer()
	return &Analyzer{
		index: indexer
		resolver: Resolver{
			indexer: indexer
		}
	}
}
