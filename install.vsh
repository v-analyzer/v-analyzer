import os
import json
import term
import time
import szip
import net.http

pub const (
	analyzer_sources_path       = norm_expand_tilde_to_home('~/.config/v-analyzer/sources')
	analyzer_bin_path           = norm_expand_tilde_to_home('~/.config/v-analyzer/bin')
	analyzer_bin_path_with_name = norm_expand_tilde_to_home('~/.config/v-analyzer/bin/v-analyzer')
)

struct ReleaseAsset {
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
	assets []ReleaseAsset
}

fn run_downloading() ! {
	println('Downloading ${term.bold('v-analyzer')}...')

	println('Fetching latest release info from GitHub...')
	text := http.get_text('https://api.github.com/repos/i582/simple_package/releases/latest')
	res := json.decode(ReleaseInfo, text) or {
		errorln('Failed to decode JSON response from GitHub: ${err}')
		return
	}

	os_ := os_name() or {
		unsupported()!
		return
	}

	arch := arch_name() or {
		unsupported()!
		return
	}

	filename := build_os_arch(os_, arch)
	asset := res.assets.filter(it.os_arch() == filename)[0] or {
		unsupported()!
		return
	}

	println('Found ${term.bold('v-analyzer')} binary for your platform: ${filename}')
	print('Downloading ${term.bold('v-analyzer')} archive')
	os.flush()

	archive_temp_dir := os.join_path(os.temp_dir(), 'v-analyzer', 'archive')
	os.mkdir_all(archive_temp_dir) or {
		println('Failed to create temp directory for archive: ${archive_temp_dir}')
		return
	}

	archive_temp_path := os.join_path(archive_temp_dir, 'v-analyzer.zip')

	ch := download_file(asset.browser_download_url, archive_temp_path)

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

	println('Path to the ${term.bold('binary')}: ${analyzer_bin_path_with_name}')

	show_hint_about_path_if_needed(analyzer_bin_path_with_name)

	os.mkdir_all(analyzer_sources_path) or {
		println('Failed to create directory: ${analyzer_sources_path}')
		return
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

fn build_os_arch(os_name string, arch string) string {
	return '${os_name}-${arch}'
}

fn unsupported() ! {
	println('${term.yellow('[WARNING]')} Currently ${term.bold('v-analyzer')} has no prebuilt binaries for your platform.')
	mut answer := os.input('Do you want to build it from sources? (y/n) ')
	if answer != 'y' {
		println('')
		println('Ending the update process.')
		warnln('${term.bold('v-analyzer')} is not installed!')
		println('')
		println('${term.bold('[NOTE]')} If you want to build it from sources manually, run the following commands:')
		println('git clone https://github.com/vlang-association/v-analyzer.git')
		println('cd v-analyzer')
		println('v build.vsh')
		println(term.gray('# Optionally you can move the binary to the standard location:'))
		println('mkdir -p ${analyzer_bin_path}')
		println('cp ./bin/v-analyzer ${analyzer_bin_path}')
		return
	}

	println('')
	println('Cloning ${term.bold('v-analyzer')} repository...')

	mut clone_command := os.Command{
		path: 'git clone https://github.com/v-analyzer/v-analyzer.git  ${analyzer_sources_path} 2>&1'
		redirect_stdout: true
	}

	clone_command.start()!

	for !clone_command.eof {
		println(clone_command.read_line())
	}

	clone_command.close()!

	if clone_command.exit_code != 0 {
		errorln('Failed to clone v-analyzer repository.')
		return
	}

	println('${term.green('✓')} ${term.bold('v-analyzer')} repository cloned successfully.')

	println('Building ${term.bold('v-analyzer')}...')

	install_deps_cmd := os.execute('cd ${analyzer_sources_path} && v install')
	if install_deps_cmd.exit_code != 0 {
		errorln('Failed to install dependencies for ${term.bold('v-analyzer')}.')
		eprintln(install_deps_cmd.output)
		return
	}

	println('${term.green('✓')} Dependencies for ${term.bold('v-analyzer')} installed successfully.')

	mut command := os.Command{
		path: 'cd ${analyzer_sources_path} && v build.vsh 1>/dev/null'
		redirect_stdout: true
	}

	command.start()!

	for !command.eof {
		println(command.read_line())
	}

	command.close()!

	if command.exit_code != 0 {
		errorln('Failed to build ${term.bold('v-analyzer')}.')
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

	println('${term.green('✓')} ${term.bold('v-analyzer')} built successfully.')
	println('Path to the ${term.bold('binary')}: ${analyzer_bin_path_with_name}')

	show_hint_about_path_if_needed(analyzer_bin_path_with_name)
}

fn show_hint_about_path_if_needed(abs_path string) {
	if !need_show_hint_about_path(abs_path) {
		return
	}

	quoted_abs_path := '"${abs_path}"'

	print('Add it to your ${term.bold('PATH')} to use it from anywhere or ')
	println('specify the full path to the binary in your editor settings.')
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
		return 'some'
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

run_downloading()!
