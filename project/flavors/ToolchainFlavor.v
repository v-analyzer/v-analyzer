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

import arrays
import os

pub interface ToolchainFlavor {
	get_home_page_candidates() []string
	is_applicable() bool
}

fn is_valid_toolchain_path(path string) bool {
	return os.is_dir(path) && has_executable(path, 'v') && has_vlib(path)
}

fn has_executable(path string, exe string) bool {
	mut with_exe := os.join_path(path, exe)
	$if windows {
		with_exe += '.exe'
	}

	return os.is_executable(with_exe)
}

fn has_vlib(path string) bool {
	vlib_path := os.join_path(path, 'vlib')
	return os.is_dir(vlib_path)
}

pub fn get_toolchain_candidates() []string {
	mut flavors := []ToolchainFlavor{}
	flavors << VenvToolchainFlavor{}
	$if !windows {
		// On Windows, a symlink to V is not created, so it makes no sense to check this option.
		flavors << SymlinkToolchainFlavor{}
	}
	flavors << SysPathToolchainFlavor{}
	flavors << UserHomeToolchainFlavor{}
	$if macos {
		flavors << MacToolchainFlavor{}
	}
	$if windows {
		flavors << WinToolchainFlavor{}
	}

	return arrays.flatten(flavors
		.filter(it.is_applicable())
		.map(it.get_home_page_candidates()))
		.filter(is_valid_toolchain_path)
}
