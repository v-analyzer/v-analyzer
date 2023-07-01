module psi

import lsp
import time
import loglib
import tree_sitter_v as v
import analyzer.parser
import v_tree_sitter.tree_sitter

[heap]
pub struct PsiFile {
pub:
	path      string
	stub_list &StubList
pub mut:
	tree        &tree_sitter.Tree[v.NodeType] = unsafe { nil }
	source_text string
	root        PsiElement
}

pub fn new_psi_file(path string, tree &tree_sitter.Tree[v.NodeType], source_text string) &PsiFile {
	mut file := &PsiFile{
		path: path
		tree: unsafe { tree }
		source_text: source_text
		stub_list: unsafe { nil }
		root: unsafe { nil }
	}
	file.root = create_element(AstNode(tree.root_node()), file)
	return file
}

pub fn new_stub_psi_file(path string, stub_list &StubList) &PsiFile {
	return &PsiFile{
		path: path
		tree: unsafe { nil }
		source_text: ''
		stub_list: stub_list
		root: unsafe { nil }
	}
}

[inline]
pub fn (p &PsiFile) is_stub_based() bool {
	return isnil(p.tree)
}

[inline]
pub fn (p &PsiFile) is_test_file() bool {
	return p.path.ends_with('_test.v')
}

[inline]
pub fn (p &PsiFile) is_shell_script() bool {
	return p.path.ends_with('.vsh')
}

[inline]
pub fn (p &PsiFile) index_sink() ?StubIndexSink {
	return stubs_index.get_sink_for_file(p.path)
}

pub fn (mut p PsiFile) reparse(new_code string) {
	now := time.now()
	unsafe { p.tree.free() }
	// TODO: for some reason if we pass the old tree then trying to get the text
	// of the node gives the text at the wrong offset.
	res := parser.parse_code_with_tree(new_code, unsafe { nil })
	p.tree = res.tree
	p.source_text = res.source_text
	p.root = create_element(AstNode(res.tree.root_node()), p)

	loglib.with_duration(time.since(now)).with_fields({
		'file':   p.path
		'length': p.source_text.len.str()
	}).info('Reparsed file')
}

[inline]
pub fn (p &PsiFile) path() string {
	return p.path
}

[inline]
pub fn (p &PsiFile) uri() string {
	return lsp.document_uri_from_path(p.path)
}

[inline]
pub fn (p &PsiFile) text() string {
	return p.source_text
}

pub fn (p &PsiFile) symbol_at(range TextRange) u8 {
	lines := p.source_text.split_into_lines()
	line := lines[range.line] or { return 0 }
	return line[range.column - 1] or { return 0 }
}

pub fn (p &PsiFile) root() PsiElement {
	if p.is_stub_based() {
		return p.stub_list.root().get_psi() or { return p.root }
	}

	return p.root
}

[inline]
pub fn (p &PsiFile) find_element_at(offset u32) ?PsiElement {
	return p.root.find_element_at(offset)
}

pub fn (p &PsiFile) find_reference_at(offset u32) ?ReferenceExpressionBase {
	element := p.find_element_at(offset)?
	if element is ReferenceExpressionBase {
		return element
	}
	if element is Identifier {
		parent := element.parent()?
		if parent is ReferenceExpressionBase {
			return parent
		}
	}
	return none
}

[inline]
pub fn (p &PsiFile) module_fqn() string {
	return stubs_index.get_module_qualified_name(p.path)
}

pub fn (p &PsiFile) module_name() ?string {
	module_clause := p.root().find_child_by_type_or_stub(.module_clause)?

	if module_clause is ModuleClause {
		return module_clause.name()
	}

	return none
}

pub fn (p &PsiFile) module_clause() ?&ModuleClause {
	module_clause := p.root().find_child_by_type_or_stub(.module_clause)?

	if module_clause is ModuleClause {
		return module_clause
	}

	return none
}

pub fn (p &PsiFile) get_imports() []ImportSpec {
	import_list := p.root().find_child_by_type_or_stub(.import_list) or { return [] }
	declarations := import_list.find_children_by_type_or_stub(.import_declaration)
	mut import_specs := []ImportSpec{cap: declarations.len}
	for declaration in declarations {
		spec := declaration.find_child_by_type_or_stub(.import_spec) or { continue }
		if spec is ImportSpec {
			import_specs << spec
		}
	}
	return import_specs
}

pub fn (p &PsiFile) resolve_import_spec(name string) ?ImportSpec {
	imports := p.get_imports()
	if imports.len == 0 {
		return none
	}

	for imp in imports {
		if imp.import_name() == name {
			return imp
		}
	}

	return none
}

pub fn (p &PsiFile) process_declarations(mut processor PsiScopeProcessor) bool {
	children := p.root.children()
	for child in children {
		// if child is PsiNamedElement {
		// 	if !processor.execute(child as PsiElement) {
		// 		return false
		// 	}
		// }
		if child is ConstantDeclaration {
			for constant in child.constants() {
				if constant is PsiNamedElement {
					if !processor.execute(constant as PsiElement) {
						return false
					}
				}
			}
		}
	}

	return true
}
