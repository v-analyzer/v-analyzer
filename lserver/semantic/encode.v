module semantic

pub fn encode(tokens []SemanticToken) []u32 {
	mut result := tokens.clone()
	result.sort_with_compare(fn (left &SemanticToken, right &SemanticToken) int {
		if left.line != right.line {
			if left.line < right.line {
				return -1
			}
			if left.line > right.line {
				return 1
			}
		}
		if left.start < right.start {
			return -1
		}

		if left.start > right.start {
			return 1
		}

		return 0
	})

	mut res := []u32{len: result.len * 5}

	mut cur := 0
	mut last := SemanticToken{}
	for tok in result {
		typ := u32(tok.typ)
		if cur == 0 {
			res[cur] = tok.line
		} else {
			res[cur] = tok.line - last.line
		}
		res[cur + 1] = tok.start
		if cur > 0 && res[cur] == 0 {
			res[cur + 1] = tok.start - last.start
		}
		res[cur + 2] = tok.len
		res[cur + 3] = typ // for now
		res[cur + 4] = if 'mutable' in tok.mods { u32(0b010000000000) } else { u32(0) }
		cur += 5
		last = tok
	}

	return res[..cur]
}
