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
