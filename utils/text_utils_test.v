module utils

fn test_pascal_case_to_snake_case() {
	assert pascal_case_to_snake_case('CamelCase') == 'camel_case'
	assert pascal_case_to_snake_case('SomeValue') == 'some_value'
	assert pascal_case_to_snake_case('SomeValue') == 'some_value'
	assert pascal_case_to_snake_case('SomeValue1') == 'some_value_1'
	assert pascal_case_to_snake_case('Some') == 'some'
}
