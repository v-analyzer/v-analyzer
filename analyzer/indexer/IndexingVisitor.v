module indexer

import analyzer.ir

// IndexingVisitor инкапсулирует логику построения индекса для файла.
//
// Его основная цель собрать информацию о символах определенных в файле и
// сохранить ее в кэш.
struct IndexingVisitor {
	filepath string
	file     &ir.File
mut:
	cache &FileCache
}

// visit посещает каждый узел в дереве и собирает информацию о символах.
fn (mut i IndexingVisitor) visit(node ir.Node) bool {
	match node {
		ir.ModuleClause {
			i.cache.module_name = node.name.value.trim(' ')
			i.cache.module_fqn = node.name.value.trim(' ') // TODO: рассчитывать имя для вложенных модулей
		}
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
	module_name := i.cache.module_name

	if module_name == '' || module_name == 'builtin' || module_name == 'main' {
		return name
	}

	return module_name + '.' + name
}

// pos возвращает позицию в исходном коде для узла.
fn (mut _ IndexingVisitor) pos(node ir.Node) Pos {
	sp := node.node.raw_node.start_point()
	end_sp := node.node.raw_node.end_point()
	return Pos{
		line: int(sp.row)
		column: int(sp.column)
		end_line: int(end_sp.row)
		end_column: int(end_sp.column)
	}
}
