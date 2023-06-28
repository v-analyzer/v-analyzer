import os
import term
import cli

pub const (
	code_path          = './cmd/v-analyzer'
	bin_path           = './bin/v-analyzer'
	base_build_command = '${@VEXE} ${code_path} -o ${bin_path}'
)

fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

// debug builds the v-analyzer binary in debug mode.
// This is the default mode.
// Thanks to -d use_libbacktrace, the binary will print beautiful stack traces,
// which is very useful for debugging.
fn debug() os.Result {
	return os.execute('${base_build_command} -g -d use_libbacktrace')
}

// release builds the v-analyzer binary in release mode.
// This is the recommended mode for production use.
// It is about 30-40% faster than debug mode.
fn release() os.Result {
	return os.execute('${base_build_command} -w -cflags "-O3 -DNDEBUG" -prod')
}

fn prepare_output_dir() {
	if os.exists('./bin') {
		return
	}
	os.mkdir('./bin') or { errorln('Failed to create output directory: ${err}') }
}

fn build(explicit_debug bool, release_mode bool) {
	println('Building v-analyzer...')

	prepare_output_dir()
	println('${term.green('✓')} Prepared output directory')

	cmd := if release_mode { release } else { debug }
	cmd_name := if release_mode { 'release' } else { 'debug' }
	println('Building v-analyzer in ${term.bold(cmd_name)} mode...')
	if release_mode {
		println('This may take a while...')
	}

	if !explicit_debug && !release_mode {
		println('To build in ${term.bold('release')} mode, run ${term.bold('v build.vsh release')}')
		println('Release mode is recommended for production use. It is about 30-40% faster than debug mode.')
	}

	res := cmd()
	if res.exit_code != 0 {
		errorln('Failed to build v-analyzer')
		eprintln(res.output)
	}

	println('${term.green('✓')} Successfully built v-analyzer!')
	println('Binary is located at ${term.bold(abs_path(bin_path))}')
}

mut cmd := cli.Command{
	name: 'v-analyzer-builder'
	version: '0.0.1-alpha'
	description: 'Builds the v-analyzer binary.'
	posix_mode: true
	execute: fn (_ cli.Command) ! {
		build(false, false)
	}
}

cmd.add_command(cli.Command{
	name: 'debug'
	description: 'Builds the v-analyzer binary in debug mode.'
	execute: fn (_ cli.Command) ! {
		build(true, false)
	}
})

cmd.add_command(cli.Command{
	name: 'release'
	description: 'Builds the v-analyzer binary in release mode.'
	execute: fn (_ cli.Command) ! {
		build(false, true)
	}
})

cmd.parse(os.args)
