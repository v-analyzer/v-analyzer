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
import term
import utils

pub const analyzer_install_script_download_path = 'https://raw.githubusercontent.com/v-analyzer/v-analyzer/main/install.vsh'

pub const analyzer_install_script_path = utils.expand_tilde_to_home('~/.config/v-analyzer/install.vsh')

fn up_cmd(cmd cli.Command) ! {
	download_install_vsh()!

	is_nightly := cmd.flags.get_bool('nightly') or { false }
	nightly_flag := if is_nightly { '--nightly' } else { '' }

	command := 'up ${nightly_flag}'
	exit_code := call_install_vsh(command)!

	if exit_code != 0 {
		errorln('Failed to update ${term.bold('v-analyzer')}')
		return
	}
}
