#!/usr/bin/env -S v

// This script is used to install and update v-analyzer.
import os
import json
import term
import time
import compress.szip
import cli
import net.http

pub const installer_version = '0.0.2'
pub const analyzer_sources_path = norm_expand_tilde_to_home('~/.config/v-analyzer/sources')
pub const analyzer_bin_path = norm_expand_tilde_to_home('~/.config/v-analyzer/bin')
pub const analyzer_bin_path_with_name = norm_expand_tilde_to_home('~/.config/v-analyzer/bin/v-analyzer')

struct ReleaseAsset {
	tag_name             string @[json: '-']
	browser_download_url string
}

fn (a ReleaseAsset) name() string {
	return a.browser_download_url
		.all_after_last('/')
		.trim_string_right('.zip')
}

fn (a ReleaseAsset) os_arch() string {
	name := a.name()
	parts := name.split('-')
	return parts[2..].join('-')
}

struct ReleaseInfo {
	tag_name string
	assets   []ReleaseAsset
}

fn current_version() !string {
	version_res := os.execute('v-analyzer --version')
	if version_res.exit_code != 0 {
		return error('Failed to get current version: ${version_res.output}')
	}

	return version_res.output.trim_string_left('v-analyzer version ').trim_space()
}

fn check_updates() ! {
	asset := find_latest_asset() or {
		if err.msg().starts_with('Unsupported') {
			update_from_sources(true, false)!
			return
		}
		errorln('Failed to find latest release: ${err}')
		return
	}

	cur_version := current_version() or {
		errorln('${err}')
		return
	}

	if cur_version.trim_string_left('v') == asset.tag_name.trim_string_left('v') {
		println('You already have the latest version of ${term.bold('v-analyzer')}: ${cur_version}')
		return
	}

	println('New version of ${term.bold('v-analyzer')} is available: ${term.bold(asset.tag_name)}')
}

fn update(nightly bool) ! {
	if nightly {
		println('Installing latest nightly version...')
		update_from_sources(true, true)!
		return
	}

	println('Checking for updates...')

	println('Fetching latest release info from GitHub...')
	asset := find_latest_asset() or {
		if err.msg().starts_with('Unsupported') {
			update_from_sources(true, false)!
			return
		}
		errorln('Failed to find latest release: ${err}')
		return
	}

	cur_version := current_version() or {
		errorln('${err}')
		return
	}
	asset_version := asset.tag_name

	if cur_version.trim_string_left('v') == asset_version.trim_string_left('v') {
		println('You already have the latest version of ${term.bold('v-analyzer')}: ${cur_version}')
		return
	}

	println('Found new version of ${term.bold('v-analyzer')}: ${asset_version}')
	install_from_binary(asset, true)!
}

fn install(no_interaction bool) ! {
	println('Downloading ${term.bold('v-analyzer')}...')

	println('Fetching latest release info from GitHub...')
	asset := find_latest_asset() or {
		install_from_sources(no_interaction)!
		return
	}

	println('Found ${term.bold('v-analyzer')} binary for your platform: ${asset.os_arch()}')
	install_from_binary(asset, false)!
}

fn install_from_binary(asset ReleaseAsset, update bool) ! {
	print('Downloading ${term.bold('v-analyzer')} archive')
	os.flush()

	archive_temp_dir := os.join_path(os.temp_dir(), 'v-analyzer', 'archive')
	os.mkdir_all(archive_temp_dir) or {
		println('Failed to create temp directory for archive: ${archive_temp_dir}')
		return
	}

	archive_temp_path := os.join_path(archive_temp_dir, 'v-analyzer.zip')

	download_file_with_progress(asset.browser_download_url, archive_temp_path)

	println('${term.green('✓')} Successfully downloaded ${term.bold('v-analyzer')} archive')

	println('Extracting ${term.bold('v-analyzer')} archive...')
	os.mkdir_all(analyzer_bin_path) or {
		println('Failed to create directory: ${analyzer_bin_path}')
		return
	}

	szip.extract_zip_to_dir(archive_temp_path, analyzer_bin_path) or {
		println('Failed to extract archive: ${err}')
		return
	}

	println('${term.green('✓')} Successfully extracted ${term.bold('v-analyzer')} archive')

	if update {
		println('${term.green('✓')} ${term.bold('v-analyzer')} successfully updated to ${term.bold(asset.tag_name)}')
	}

	println('Path to the ${term.bold('binary')}: ${analyzer_bin_path_with_name}')

	if !update {
		show_hint_about_path_if_needed(analyzer_bin_path_with_name)
	}

	os.mkdir_all(analyzer_sources_path) or {
		println('Failed to create directory: ${analyzer_sources_path}')
		return
	}
}

fn find_latest_asset() !ReleaseAsset {
	text := http.get_text('https://api.github.com/repos/v-analyzer/v-analyzer/releases/latest')
	res := json.decode(ReleaseInfo, text) or {
		errorln('Failed to decode JSON response from GitHub: ${err}')
		return error('Failed to decode JSON response from GitHub: ${err}')
	}

	os_ := os_name() or { return error('Unsupported OS') }

	arch := arch_name() or { return error('Unsupported architecture') }

	filename := build_os_arch(os_, arch)
	asset := res.assets.filter(it.os_arch() == filename)[0] or {
		return error('Unsupported OS or architecture')
	}

	return ReleaseAsset{
		...asset
		tag_name: res.tag_name
	}
}

// download_file downloads file from the given URL to the given path.
// Returns channel that will be closed when the download is finished.
// If the download fails, the channel will be closed with false value.
fn download_file(path string, to string) chan bool {
	ch := chan bool{}

	spawn fn [ch, path, to] () {
		http.download_file(path, to) or {
			println('Failed to download file: ${err}')
			ch <- false
			ch.close()
			return
		}
		ch <- true
		ch.close()
	}()

	return ch
}

fn download_file_with_progress(path string, to string) {
	ch := download_file(path, to)

	for {
		select {
			_ := <-ch {
				println('')
				break
			}
			500 * time.millisecond {
				print('.')
				os.flush()
			}
		}
	}
}

fn build_os_arch(os_name string, arch string) string {
	return '${os_name}-${arch}'
}

fn update_from_sources(update bool, nightly bool) ! {
	mut need_pull := true
	if !already_cloned() {
		clone_repository()!
		need_pull = false
	}

	if need_pull {
		println('Updating ${term.bold('v-analyzer')} sources...')

		res := os.execute('git -C ${analyzer_sources_path} pull')
		if res.exit_code != 0 {
			errorln('Failed to update sources: ${res.output}')
			return
		}

		println('${term.green('✓')} Successfully updated ${term.bold('v-analyzer')} sources')
	}

	build_from_sources()!

	if update {
		hash := get_latest_commit_hash() or {
			errorln(err.str())
			return
		}

		updated_version := if nightly {
			'nightly (${hash})'
		} else {
			hash
		}

		println('${term.green('✓')} ${term.bold('v-analyzer')} successfully updated to ${updated_version}')
	}

	println('Path to the ${term.bold('binary')}: ${analyzer_bin_path_with_name}')
	return
}

fn get_latest_commit_hash() !string {
	hash_res := os.execute('git -C ${analyzer_sources_path} log -1 --format=%H')
	if hash_res.exit_code != 0 {
		return error('Failed to get hash of the latest commit: ${hash_res.output}')
	}
	return hash_res.output.trim_space()
}

fn install_from_sources(no_interaction bool) ! {
	println('${term.yellow('[WARNING]')} Currently ${term.bold('v-analyzer')} has no prebuilt binaries for your platform')

	// Used primarily for VS Code extension
	if !no_interaction {
		mut answer := os.input('Do you want to build it from sources? (y/n) ')
		if answer != 'y' {
			println('')
			println('Ending the update process')
			warnln('${term.bold('v-analyzer')} is not installed!')
			println('')
			println('${term.bold('[NOTE]')} If you want to build it from sources manually, run the following commands:')
			println('git clone https://github.com/v-analyzer/v-analyzer.git')
			println('cd v-analyzer')
			println('v build.vsh')
			println(term.gray('# Optionally you can move the binary to the standard location:'))
			println('mkdir -p ${analyzer_bin_path}')
			println('cp ./bin/v-analyzer ${analyzer_bin_path}')
			return
		}
	}

	if already_cloned() {
		os.rmdir_all(analyzer_sources_path) or {
			errorln('Failed to remove directory: ${analyzer_sources_path}: ${err}')
			return
		}
	}

	println('')

	clone_repository()!
	build_from_sources()!

	println('Path to the ${term.bold('binary')}: ${analyzer_bin_path_with_name}')

	show_hint_about_path_if_needed(analyzer_bin_path_with_name)
}

fn clone_repository() ! {
	println('Cloning ${term.bold('v-analyzer')} repository...')

	exit_code := run_command('git clone https://github.com/v-analyzer/v-analyzer.git ${analyzer_sources_path} 2>&1') or {
		errorln('Failed to clone v-analyzer repository: ${err}')
		return
	}
	if exit_code != 0 {
		errorln('Failed to clone v-analyzer repository')
		return
	}

	println('${term.green('✓')} ${term.bold('v-analyzer')} repository cloned successfully')
}

fn build_from_sources() ! {
	println('Building ${term.bold('v-analyzer')}...')

	compiler_flag := $if windows { '-cc gcc' } $else { '' }

	chdir(analyzer_sources_path)!
	install_deps_cmd := os.execute('v ${compiler_flag} install')
	if install_deps_cmd.exit_code != 0 {
		errorln('Failed to install dependencies for ${term.bold('v-analyzer')}')
		eprintln(install_deps_cmd.output)
		return
	}

	println('${term.green('✓')} Dependencies for ${term.bold('v-analyzer')} installed successfully')

	chdir(analyzer_sources_path)!
	exit_code := run_command('v ${compiler_flag} build.vsh 1>/dev/null') or {
		errorln('Failed to build ${term.bold('v-analyzer')}: ${err}')
		return
	}
	if exit_code != 0 {
		errorln('Failed to build ${term.bold('v-analyzer')}')
		return
	}

	println('Moving ${term.bold('v-analyzer')} binary to the standard location...')

	os.mkdir_all(analyzer_bin_path) or {
		println('Failed to create directory: ${analyzer_bin_path}')
		return
	}

	os.cp_all('${analyzer_sources_path}/bin/v-analyzer', analyzer_bin_path, true) or {
		println('Failed to copy ${term.bold('v-analyzer')} binary to ${analyzer_bin_path}: ${err}')
		return
	}

	println('${term.green('✓')} Successfully moved ${term.bold('v-analyzer')} binary to ${analyzer_bin_path}')

	println('${term.green('✓')} ${term.bold('v-analyzer')} built successfully')
}

fn already_cloned() bool {
	if !os.exists(analyzer_sources_path) {
		return false
	}

	files := os.ls(analyzer_sources_path) or { return false }
	return files.len > 0
}

fn show_hint_about_path_if_needed(abs_path string) {
	if !need_show_hint_about_path(abs_path) {
		return
	}

	quoted_abs_path := '"${abs_path}"'

	print('Add it to your ${term.bold('PATH')} to use it from anywhere or ')
	println('specify the full path to the binary in your editor settings')
	println('')
	print('For example in VS Code ')
	println(term.bold('settings.json:'))
	println('${term.bold('{')}')
	println('    ${term.yellow('"v-analyzer.serverPath"')}: ${term.green(quoted_abs_path)}')
	println('${term.bold('}')}')
}

fn need_show_hint_about_path(abs_path string) bool {
	dir := os.dir(abs_path)
	path := os.getenv('PATH')
	paths := path.split(os.path_delimiter)
	return paths.filter(it == dir).len == 0
}

fn os_name() ?string {
	$if macos {
		return 'darwin'
	}
	name := os.user_os()
	if name == 'unknown' {
		return none
	}
	return name
}

fn arch_name() ?string {
	$if arm64 {
		return 'arm64'
	}

	$if amd64 || x64 {
		return 'x86_64'
	}

	return none
}

fn run_command(cmd string) !int {
	$if windows {
		fixed_command := cmd
			.trim_string_right('2>&1')
			.trim_string_right('1>/dev/null')

		res := os.execute(fixed_command)
		println(res.output)

		return res.exit_code
	}

	mut command := os.Command{
		path: cmd
		redirect_stdout: true
	}

	command.start()!

	for !command.eof {
		println(command.read_line())
	}

	command.close()!

	return command.exit_code
}

fn norm_expand_tilde_to_home(path string) string {
	norm_path := os.norm_path(path)
	return os.expand_tilde_to_home(norm_path)
}

pub fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

pub fn warnln(msg string) {
	println('${term.yellow('[WARNING]')} ${msg}')
}

mut cmd := cli.Command{
	name: 'v-analyzer-installer-updated'
	version: installer_version
	description: 'Install and update v-analyzer'
	posix_mode: true
	execute: fn (cmd cli.Command) ! {
		no_interaction := cmd.flags.get_bool('no-interaction') or { os.getenv('GITHUB_JOB') != '' }
		install(no_interaction)!
	}
	flags: [
		cli.Flag{
			flag: .bool
			name: 'no-interaction' // Used primarily for VS Code extension, to install v-analyzer from sources
			description: 'Do not ask any questions, use default values'
		},
	]
}

cmd.add_command(cli.Command{
	name: 'up'
	description: 'Update v-analyzer to the latest version'
	posix_mode: true
	execute: fn (cmd cli.Command) ! {
		nightly := cmd.flags.get_bool('nightly') or { false }
		update(nightly)!
	}
	flags: [
		cli.Flag{
			flag: .bool
			name: 'nightly'
			description: 'Install the latest nightly build'
		},
	]
})

cmd.add_command(cli.Command{
	name: 'check-availability'
	description: 'Check if v-analyzer binary is available for the current platform (service command for editors)'
	posix_mode: true
	execute: fn (_ cli.Command) ! {
		find_latest_asset() or {
			println('Prebuild v-analyzer binary is not available for your platform')
			return
		}

		println('${term.green('✓')} Prebuild v-analyzer binary is available for your platform')
	}
})

cmd.add_command(cli.Command{
	name: 'check-updates'
	description: 'Checks for v-analyzer updates.'
	posix_mode: true
	execute: fn (_ cli.Command) ! {
		check_updates()!
	}
})

cmd.parse(os.args)
