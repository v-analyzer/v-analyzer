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
