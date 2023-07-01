module main

import os
import cli
import term
import utils
import net.http

pub const (
	analyzer_install_script_download_path = 'https://raw.githubusercontent.com/v-analyzer/v-analyzer/main/install.vsh'
	analyzer_install_script_path          = utils.expand_tilde_to_home('~/.config/v-analyzer/install.vsh')
)

fn up_cmd(cmd cli.Command) ! {
	http.download_file(analyzer_install_script_download_path, analyzer_install_script_path) or {
		errorln('Failed to download script: ${err}')
		return
	}

	is_nightly := cmd.flags.get_bool('nightly') or { false }
	nightly_flag := if is_nightly { '--nightly' } else { '' }

	$if windows {
		// On Windows we cannot use `os.Command` because it doesn't support Windows
		res := os.execute('v ${analyzer_install_script_path} up ${nightly_flag}')
		if res.exit_code != 0 {
			errorln('Failed to update ${term.bold('v-analyzer')}')
			return
		}
		return
	}

	mut command := os.Command{
		path: 'v ${analyzer_install_script_path} up ${nightly_flag}'
		redirect_stdout: true
	}

	command.start()!

	for !command.eof {
		println(command.read_line())
	}

	command.close()!

	if command.exit_code != 0 {
		errorln('Failed to update ${term.bold('v-analyzer')}')
		return
	}
}
