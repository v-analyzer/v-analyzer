module psi

pub struct FunctionDeclaration {
	PsiElementImpl
}

pub fn (f FunctionDeclaration) identifier() ?PsiElement {
	return f.find_child_by_type(.identifier) or { return none }
}

pub fn (f FunctionDeclaration) signature() ?&Signature {
	signature := f.find_child_by_type(.signature) or { return none }
	if signature is Signature {
		return signature
	}
	return none
}

pub fn (f FunctionDeclaration) name() string {
	identifier := f.identifier() or { return '' }
	return identifier.get_text()
}

pub fn (f FunctionDeclaration) doc_comment() string {
	mut comment := f.prev_sibling() or { return '' }

	mut comments := []PsiElement{}

	for comment is Comment {
		func_start_line := f.node.start_point().row
		comment_start_line := comment.node.start_point().row

		if comment_start_line + 1 + u32(comments.len) != func_start_line {
			break
		}

		comments << comment
		comment = comment.prev_sibling() or { break }
	}

	comments.reverse_in_place()

	return comments
		.map(it.get_text().trim_string_left('//')
			.trim_right(' \t'))
		.map(process_line)
		.join('\n')
}

fn process_line(line string) string {
	if line.ends_with('.') || line.ends_with('!') || line.ends_with('?') {
		return line + '\n'
	}

	if line.starts_with('-') || line.starts_with('|') || line.ends_with('|') {
		return line + '\n'
	}

	if line.trim(' ').to_lower() == 'example:' {
		return '\n' + line
	}

	return line
}
