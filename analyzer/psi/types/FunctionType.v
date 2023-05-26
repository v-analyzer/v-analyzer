module types

import strings

pub struct FunctionType {
pub:
	params    []Type
	result    Type
	no_result bool
}

pub fn new_function_type(params []Type, result Type, no_result bool) &FunctionType {
	return &FunctionType{
		params: params
		result: result
		no_result: no_result
	}
}

pub fn (s &FunctionType) name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.name())
		if index < s.params.len - 1 {
			sb.write_string(',')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.name())
	}

	return sb.str()
}

pub fn (s &FunctionType) qualified_name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.qualified_name())
		if index < s.params.len - 1 {
			sb.write_string(',')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.qualified_name())
	}

	return sb.str()
}

pub fn (s &FunctionType) readable_name() string {
	mut sb := strings.new_builder(20)
	sb.write_string('fn (')
	for index, param in s.params {
		sb.write_string(param.readable_name())
		if index < s.params.len - 1 {
			sb.write_string(',')
		}
	}
	sb.write_string(')')
	if !s.no_result {
		sb.write_string(' ')
		sb.write_string(s.result.readable_name())
	}

	return sb.str()
}
