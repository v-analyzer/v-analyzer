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
module stubs

// element_type is the type of the elements in the array.
type element_type = any

// ArrayInit describes an array initializer.
// Example:
// ```
// arr := []int{}
// arr_with_len := []int{len: 1} // [0]
// arr_with_cap := []int{len: 1, cap: 100} // [0]
// arr_with_len_init := []int{len: 1, init: 1} [1]
// arr_with_init := []int{len: 2, cap: 100, init: index * 2} [0, 2]
// ```
//
// Array initializer can contain three **optional** fields:
// 1. `len` – length – number of pre-allocated and initialized elements in the array
// 2. `cap` – capacity – amount of memory space which has been reserved for elements,
//            but not initialized or counted as elements
// 3. `init` – default initializer for each element
//
// All three fields can be used independently of the others.
//
// # cap field
//
// If `cap` is not specified, it is set to `len`. `cap` cannot be smaller than `len`.
// `cap` can be used for improving performance of array operations, since no reallocation will be needed.
//
// ```
// arr := []int{len: 2}
// arr << 100 // there will be a reallocation that will slow down the program a bit
//
// arr_with_cap := []int{len: 2, cap: 10}
// arr_with_cap << 100 // no reallocation
// ```
//
// # init field
//
// If `init` is not specified, it is set to `0` for numerical type, `''` for string, etc.
//
// ```
// arr := []int{len: 2}
// assert arr == [0, 0]
// ```
//
// In `init` field, you can use special `index` variable to refer to the current index.
//
// ```
// arr := []int{len: 3, init: index * 2}
// assert arr == [0, 2, 4]
// ```
pub struct ArrayInit {
	// index represent the current element index that is being initialized inside `init`.
	//
	// **Example**
	// ```
	// arr := []int{len: 3, init: index * 2}
	// assert arr == [0, 2, 4]
	// ```
	index int
pub:
	// len field represent number of pre-allocated and initialized elements in the array.
	// By default it is set to `0` for numerical type, `''` for string, etc.
	//
	// **Example**
	// ```
	// arr := []int{len: 3}
	// assert arr.len == 3
	// assert arr[0] == 0
	// assert arr[1] == 0
	// assert arr[2] == 0
	// ```
	len int

	// cap field represent amount of memory space which has been reserved for elements,
	// but not initialized or counted as elements
	//
	// If `cap` is not specified, it is set to `len`. `cap` cannot be smaller than `len`.
	// `cap` can be used for improving performance of array operations, since no reallocation will be needed.
	//
	// **Example**
	// ```
	// arr := []int{len: 2}
	// arr << 100 // there will be a reallocation that will slow down the program a bit
	// arr_with_cap := []int{len: 2, cap: 10}
	// arr_with_cap << 100 // no reallocation
	// ```
	cap int

	// init field represent default initializer for each element.
	//
	// In `init` field, you can use special `index` variable to refer to the current index.
	//
	// **Example**
	// ```
	// arr := []int{len: 3, init: index * 2}
	// assert arr == [0, 2, 4]
	// ```
	//
	// If `init` is not specified, it is set to `0` for numerical type, `''` for string, etc.
	//
	// **Example**
	// ```
	// arr := []int{len: 2}
	// assert arr == [0, 0]
	// ```
	init element_type
}
