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
import net.http

pub fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

pub fn warnln(msg string) {
	println('${term.yellow('[WARN]')} ${msg}')
}

pub fn infoln(msg string) {
	println('${term.blue('[INFO]')} ${msg}')
}

pub fn successln(msg string) {
	println('${term.green('[SUCCESS]')} ${msg}')
}

pub fn download_install_vsh() ! {
	if os.exists(analyzer_install_script_path) {
		return
	}

	http.download_file(analyzer_install_script_download_path, analyzer_install_script_path) or {
		return error('Failed to download script: ${err}')
	}
}

pub fn call_install_vsh(cmd string) !int {
	$if windows {
		// On Windows we cannot use `os.Command` because it doesn't support Windows
		res := os.execute('v ${analyzer_install_script_path} ${cmd}')
		println(res.output)
		return res.exit_code
	}

	mut command := os.Command{
		path: 'v ${analyzer_install_script_path} ${cmd}'
		redirect_stdout: true
	}

	command.start()!

	for !command.eof {
		println(command.read_line())
	}

	command.close()!

	return command.exit_code
}
