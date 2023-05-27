module psi

pub fn extract_doc_comment(el PsiElement) string {
	mut comment := el.prev_sibling() or { return '' }
	if comment !is Comment {
		comment = comment.prev_sibling() or { return '' }
	}

	mut comments := []PsiElement{}

	for comment is Comment {
		func_start_line := el.node.start_point().row
		comment_start_line := comment.node.start_point().row

		if comment_start_line + 1 + u32(comments.len) != func_start_line {
			break
		}

		comments << comment
		comment = comment.prev_sibling() or { break }
	}

	comments.reverse_in_place()

	return comments
		.map(it.get_text().trim_string_left('//').trim_string_left(' ')
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
