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
module main

import os
import term
import testing

fn main() {
	defer {
		os.rmdir_all(testing.temp_path) or {
			println('Failed to remove temp path: ${testing.temp_path}')
		}
	}

	mut testers := []testing.Tester{}

	testers << definitions()
	testers << implementations()
	testers << supers()
	testers << completion()
	testers << types()
	testers << documentation()

	run_only := ''

	for mut tester in testers {
		println('Running ${term.bg_blue(' ' + tester.name + ' ')}')
		tester.run(run_only)
		println('')
		tester.stats().print()
		println('')
	}

	mut all_stats := testing.TesterStats{}

	for tester in testers {
		all_stats = all_stats.merge(tester.stats())
	}

	println(term.bg_blue(' All tests: '))
	all_stats.print()

	if all_stats.failed > 0 {
		println('')
		println(term.bg_red(' Failed tests: '))
		for mut tester in testers {
			for failed_test in tester.failed_tests() {
				failed_test.print()
			}
		}

		exit(1)
	}
}
