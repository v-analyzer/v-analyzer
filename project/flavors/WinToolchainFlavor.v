module flavors

import os

pub struct WinToolchainFlavor {}

fn (s &WinToolchainFlavor) get_home_page_candidates() []string {
	program_files := os.getenv('ProgramFiles')
	if !os.exists(program_files) || !os.is_dir(program_files) {
		return []
	}

	files := os.ls(program_files) or { return [] }
	return files
		.filter(os.is_dir)
		.filter(fn (path string) bool {
			name := os.file_name(path).to_lower()
			return name == 'v' || name.starts_with('vlang')
		})
}

fn (s &WinToolchainFlavor) is_applicable() bool {
	$if windows {
		return true
	}
	return false
}
