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
module types

for i in 0 .. 10 {
	expr_type(i, 'int')
}

arr := ['str']

for val in arr {
	expr_type(val, 'string')
}

for i, val in arr {
	expr_type(i, 'int')
	expr_type(val, 'string')
}

fixed_arr := ['str']!
expr_type(fixed_arr, '[1]string')

for val in fixed_arr {
	expr_type(val, 'string')
}

for i, val in fixed_arr {
	expr_type(i, 'int')
	expr_type(val, 'string')
}

mp := map[string]int{}

for key, val in mp {
	expr_type(key, 'string')
	expr_type(val, 'int')
}

type MyMap = map[string]int

mp2 := MyMap{}

for key, val in mp2 {
	expr_type(key, 'string')
	expr_type(val, 'int')
}

for val in 'hello' {
	expr_type(val, 'u8')
}

struct Iterator {}

fn (mut i Iterator) next() ?int {
	return 1
}

it := Iterator{}
for val in it {
	expr_type(val, 'int')
}
