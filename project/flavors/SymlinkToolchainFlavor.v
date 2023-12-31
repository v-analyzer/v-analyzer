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
module flavors

import os
import utils

pub struct SymlinkToolchainFlavor {}

fn (s &SymlinkToolchainFlavor) get_home_page_candidates() []string {
	symlink_path_candidates := ['/usr/local/bin/v', utils.expand_tilde_to_home('~/.local/bin/v')]

	mut result := []string{}

	for symlink_path_candidate in symlink_path_candidates {
		path_to_compiler := os.real_path(symlink_path_candidate)
		if path_to_compiler == '' {
			continue
		}

		compiler_dir := os.dir(path_to_compiler)
		if os.is_dir(compiler_dir) {
			result << compiler_dir
		}
	}

	return result
}

fn (s &SymlinkToolchainFlavor) is_applicable() bool {
	$if linux || macos || openbsd || freebsd || netbsd {
		return true
	}

	return false
}
