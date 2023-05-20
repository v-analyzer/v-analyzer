module project

import project.flavors
import os

pub fn get_modules_location() string {
	vmodules_path := os.getenv_opt('VMODULES') or { return default_modules_location() }
	paths := vmodules_path.split(os.path_delimiter)
	if paths.len == 0 {
		return ''
	}
	return paths.first()
}

fn default_modules_location() string {
	return os.expand_tilde_to_home('~/.vmodules')
}

pub fn get_toolchain_candidates() []string {
	return flavors.get_toolchain_candidates()
}
