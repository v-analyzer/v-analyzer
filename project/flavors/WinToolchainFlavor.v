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

pub struct WinToolchainFlavor {}

fn (s &WinToolchainFlavor) get_home_page_candidates() []string {
	mut res := []string{}
	result := os.execute('where v')
	if result.exit_code == 0 {
		res << os.dir(result.output.trim_space())
	}

	program_files := os.getenv('ProgramFiles')
	if !os.exists(program_files) || !os.is_dir(program_files) {
		return res
	}

	if files := os.ls(program_files) {
		res << files
			.filter(os.is_dir)
			.filter(fn (path string) bool {
				name := os.file_name(path).to_lower()
				return name == 'v' || name.starts_with('vlang')
			})
	}
	return res
}

fn (s &WinToolchainFlavor) is_applicable() bool {
	$if windows {
		return true
	}
	return false
}
