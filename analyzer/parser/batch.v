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
module parser

import sync

pub fn parse_batch_files(files []string, count_workers int) []ParseResult {
	effective_workers := if files.len < count_workers {
		files.len
	} else {
		count_workers
	}

	file_chan := chan string{cap: 1000}
	result_chan := chan ParseResult{cap: 1000}

	spawn fn [file_chan, files] () {
		for file in files {
			file_chan <- file
		}
		file_chan.close()
	}()

	spawn spawn_parser_workers(result_chan, file_chan, effective_workers)

	mut results := []ParseResult{cap: 100}
	for {
		result := <-result_chan or { break }
		results << result
	}
	return results
}

fn spawn_parser_workers(result_chan chan ParseResult, file_chan chan string, count_workers int) {
	mut wg := sync.new_waitgroup()
	wg.add(count_workers)
	for i := 0; i < count_workers; i++ {
		spawn fn [file_chan, mut wg, result_chan] () {
			for {
				filepath := <-file_chan or { break }
				mut result := parse_file(filepath) or { continue }
				result.path = filepath
				result_chan <- result
			}

			wg.done()
		}()
	}

	wg.wait()
	result_chan.close()
}
