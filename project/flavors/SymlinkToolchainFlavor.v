module flavors

import os

pub struct SymlinkToolchainFlavor {}

fn (s &SymlinkToolchainFlavor) get_home_page_candidates() []string {
	symlink_path := '/usr/local/bin/v'
	path_to_compiler := os.real_path(symlink_path)
	if path_to_compiler == '' {
		return []
	}

	compiler_dir := os.dir(path_to_compiler)
	if os.is_dir(compiler_dir) {
		return [compiler_dir]
	}
	return []
}

fn (s &SymlinkToolchainFlavor) is_applicable() bool {
	$if linux || macos || openbsd || freebsd || netbsd {
		return true
	}

	return false
}
