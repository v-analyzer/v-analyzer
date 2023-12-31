// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module psi

pub struct ImportSpec {
	PsiElementImpl
}

fn (_ &ImportSpec) stub() {}

pub fn (_ &ImportSpec) is_public() bool {
	return true
}

fn (n &ImportSpec) identifier_text_range() TextRange {
	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

fn (n &ImportSpec) identifier() ?PsiElement {
	last_part := n.last_part()?
	if last_part is ImportName {
		return last_part
	}
	return none
}

fn (n &ImportSpec) name() string {
	return n.import_name()
}

pub fn (n &ImportSpec) qualified_name() string {
	path := n.path() or { return '' }
	return path.get_text()
}

pub fn (n ImportSpec) alias() ?PsiElement {
	return n.find_child_by_type_or_stub(.import_alias)
}

pub fn (n ImportSpec) path() ?PsiElement {
	return n.find_child_by_type_or_stub(.import_path)
}

pub fn (n ImportSpec) last_part() ?PsiElement {
	path := n.path()?
	return path.last_child_or_stub()
}

pub fn (n ImportSpec) import_name() string {
	if alias := n.alias() {
		if identifier := alias.last_child_or_stub() {
			return identifier.get_text()
		}
	}

	if last_part := n.last_part() {
		return last_part.get_text()
	}

	return ''
}

pub fn (n ImportSpec) alias_name() string {
	if alias := n.alias() {
		if identifier := alias.last_child() {
			return identifier.get_text()
		}
	}

	return ''
}

pub fn (n ImportSpec) resolve_directory() string {
	fqn := n.qualified_name()
	if fqn == '' {
		return ''
	}

	return stubs_index.get_module_root(fqn)
}
