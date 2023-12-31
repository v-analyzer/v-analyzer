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
module project

import project.flavors
import os

// get_modules_location returns the folder where V looks for and saves modules.
// The default is `~/.vmodules`, however it can be overridden with the `VMODULES` environment variable
pub fn get_modules_location() string {
	return os.vmodules_dir()
}

// get_toolchain_candidates looks for possible places where the V compiler was installed.
// The function returns an array of candidates, where the first element is the highest priority.
// If no candidate is found, then an empty array is returned.
//
// A priority:
// 1. `VROOT` or `VEXE` environment variables
// 2. Symbolic link `/usr/local/bin/v` -> `v` (except Windows)
// 3. Path from `PATH` environment variable
// 4. Other additional search options
pub fn get_toolchain_candidates() []string {
	return distinct_strings(flavors.get_toolchain_candidates())
}

fn distinct_strings(arr []string) []string {
	mut set := map[string]bool{}
	for el in arr {
		set[el] = true
	}
	return set.keys()
}
