module indexer

import analyzer.ir

struct IndexingVisitor {
	filepath string
	file     &ir.File
mut:
	cache &Cache
}

fn (mut i IndexingVisitor) visit(node ir.Node) bool {
	match node {
		ir.FunctionDeclaration {
			i.cache.functions << FunctionCache{
				filepath: i.filepath
				name: i.fqn(node.name.value)
				pos: i.pos(node)
			}
		}
		ir.StructDeclaration {
			i.cache.structs << StructCache{
				filepath: i.filepath
				name: i.fqn(node.name.value)
				pos: i.pos(node)
			}
		}
		else {}
	}
	return true
}

// fqn возвращает полное имя сущности, например, для функции
// в модуле `foo` с именем `bar` возвращает `foo.bar`.
// Если у файла не указан модуль, то возвращает имя без изменений.
// Если модуль `builtin` или `main`, то возвращает имя без изменений.
fn (mut i IndexingVisitor) fqn(name string) string {
	module_clause := i.file.module_clause or { return name }

	module_name := if module_clause is ir.ModuleClause {
		module_clause.name.value
	} else {
		return name
	}

	if module_name == 'builtin' || module_name == 'main' {
		return name
	}

	return module_name + '.' + name
}

// pos возвращает позицию в исходном коде для узла.
fn (mut i IndexingVisitor) pos(node ir.Node) Pos {
	sp := node.node.raw_node.start_point()
	return Pos{
		line: int(sp.row)
		column: int(sp.column)
	}
}
