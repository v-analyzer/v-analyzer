module analyzer

pub struct Analyzer {
pub mut:
	indexer  &Indexer
	resolver Resolver
}

pub fn new() &Analyzer {
	indexer := new_indexer()
	return &Analyzer{
		indexer: indexer
		resolver: Resolver{
			indexer: indexer
		}
	}
}
