module indexer

import analyzer.ir

struct IndexingVisitor {
	filepath string
mut:
	cache &Cache
}

fn (mut i IndexingVisitor) visit(node ir.Node) bool {
	match node {
		ir.FunctionDeclaration {
			i.cache.functions << FunctionCache{
				filepath: i.filepath
				name: node.name.value
			}
		}
		else {}
	}
	return true
}
