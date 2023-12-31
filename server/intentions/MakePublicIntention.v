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
module intentions

import lsp
import analyzer.psi
import server.tform
import server.file_diff

pub struct MakePublicIntention {
	id   string = 'v-analyzer.make_public'
	name string = 'Make public'
}

fn (_ &MakePublicIntention) is_available(ctx IntentionContext) bool {
	pos := tform.lsp_position_to_position(ctx.position)
	declaration := find_declaration_at_pos(ctx.containing_file, pos) or { return false }
	return !declaration.is_public()
}

fn (_ &MakePublicIntention) invoke(ctx IntentionContext) ?lsp.WorkspaceEdit {
	pos := tform.lsp_position_to_position(ctx.position)
	declaration := find_declaration_at_pos(ctx.containing_file, pos)?

	uri := ctx.containing_file.uri()

	mut start_line := declaration.identifier_text_range().line
	if declaration is psi.ConstantDefinition {
		decl := declaration.parent()?
		if decl is psi.ConstantDeclaration {
			start_line = decl.text_range().line
		}
	}

	mut diff := file_diff.Diff.for_file(uri)
	diff.append_to_begin(start_line, 'pub ')
	return diff.to_workspace_edit()
}
