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
module testing

pub struct BenchmarkRunner {
mut:
	benchmarks   []&Benchmark
	last_fixture &Fixture
}

pub fn (mut b BenchmarkRunner) create_or_reuse_fixture() &Fixture {
	if !isnil(b.last_fixture) {
		return b.last_fixture
	}

	mut fixture := new_fixture()
	fixture.initialize(false) or {
		println('Cannot initialize fixture: ${err}')
		return fixture
	}

	b.last_fixture = fixture
	return fixture
}

pub fn (mut b BenchmarkRunner) bench(name string, bench_func fn (mut bench Benchmark, mut fixture Fixture) !) {
	mut fixture := b.create_or_reuse_fixture()

	mut bench := &Benchmark{
		name: name
	}
	b.benchmarks << bench
	bench_func(mut bench, mut fixture) or { println('Benchmark failed: ${err}') }
}
