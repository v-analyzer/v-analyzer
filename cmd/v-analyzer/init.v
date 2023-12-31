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

import cli
import os
import config
import readline
import term

fn init_cmd(cmd cli.Command) ! {
	pwd := os.getwd()
	if pwd == '' {
		return error('Cannot get current working directory')
	}

	directory_for_config := os.join_path(pwd, config.analyzer_local_configs_folder_name)
	if !os.exists(directory_for_config) {
		os.mkdir_all(directory_for_config) or {
			return error("Cannot create '${directory_for_config}' directory for config: ${err}")
		}

		println("${term.green('✓')} Created '${config.analyzer_local_configs_folder_name}' directory for config")
	}

	config_file := os.join_path(directory_for_config, config.analyzer_config_name)
	if os.exists(config_file) {
		warnln("Config file '${config_file}' already exists")
		read_line := readline.read_line('Want to overwrite it? [y/N] ') or {
			errorln('Cannot read line: ${err}')
			'N'
		}
		overwrite := read_line.trim_space() == 'y'
		if !overwrite {
			return
		}
	}

	os.write_file(config_file, config.default) or {
		return error("Cannot write config file '${config_file}': ${err}")
	}

	println("${term.green('✓')} Successfully created config file '${config_file}'")
}
