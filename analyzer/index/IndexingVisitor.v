module index

import analyzer.psi

// IndexingVisitor инкапсулирует логику построения индекса для файла.
//
// Его основная цель собрать информацию о символах определенных в файле и
// сохранить ее в кэш.
struct IndexingVisitor {
	filepath string
	file     psi.PsiFileImpl
mut:
	cache &FileCache
}

fn (mut i IndexingVisitor) process() {
	children := i.file.root().children()
	for child in children {
		i.process_child(child)
	}
}

[inline]
fn (mut i IndexingVisitor) process_child(node psi.PsiElement) {
	match node {
		psi.ModuleClause {
			i.cache.module_name = node.name().trim(' ')
			i.cache.module_fqn = node.name().trim(' ') // TODO: рассчитывать имя для вложенных модулей
		}
		psi.FunctionDeclaration {
			i.cache.functions << FunctionCache{
				filepath: i.filepath
				module_fqn: i.cache.module_fqn
				name: i.fqn(node.name())
				pos: i.pos(node)
			}
		}
		psi.StructDeclaration {
			i.cache.structs << StructCache{
				filepath: i.filepath
				module_fqn: i.cache.module_fqn
				name: i.fqn(node.name())
				pos: i.pos(node)
			}
		}
		else {}
	}
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
fn (mut _ IndexingVisitor) pos(node psi.PsiElement) Pos {
	sp := node.node.raw_node.start_point()
	end_sp := node.node.raw_node.end_point()
	return Pos{
		line: int(sp.row)
		column: int(sp.column)
		end_line: int(end_sp.row)
		end_column: int(end_sp.column)
	}
}
