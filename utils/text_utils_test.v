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
module utils

fn test_pascal_case_to_snake_case() {
	assert pascal_case_to_snake_case('CamelCase') == 'camel_case'
	assert pascal_case_to_snake_case('SomeValue') == 'some_value'
	assert pascal_case_to_snake_case('SomeValue') == 'some_value'
	assert pascal_case_to_snake_case('SomeValue1') == 'some_value_1'
	assert pascal_case_to_snake_case('Some') == 'some'
}

fn test_snake_case_to_camel_case() {
	assert snake_case_to_camel_case('snake_case') == 'snakeCase'
	assert snake_case_to_camel_case('some_value') == 'someValue'
	assert snake_case_to_camel_case('some_value_1') == 'someValue1'
	assert snake_case_to_camel_case('some') == 'some'
}
