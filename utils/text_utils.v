module utils

pub fn pascal_case_to_snake_case(s string) string {
	mut res := ''
	for index, c in s {
		if c.ascii_str().is_upper() {
			if index > 0 {
				res += '_'
			}
			res += c.ascii_str().to_lower()
		} else {
			res += c.ascii_str()
		}
	}
	return res
}

pub fn snake_case_to_camel_case(s string) string {
	mut res := ''
	mut upper := false
	for c in s {
		if c == `_` {
			upper = true
		} else {
			if upper {
				res += c.ascii_str().to_upper()
				upper = false
			} else {
				res += c.ascii_str()
			}
		}
	}
	return res
}
