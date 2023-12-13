#!/usr/bin/env -S v

// This script is used to build the v-analyzer binary.
// Usage:
//  v build.vsh [debug|dev|release]
// By default, just `v build.vsh` will use debug mode.
import os
import cli
import term
import v.vmod

pub const version = vmod.decode(@VMOD_FILE) or { panic(err) }.version
pub const code_path = './cmd/v-analyzer'
pub const bin_path = './bin/v-analyzer' + $if windows { '.exe' } $else { '' }
pub const base_build_command = '${@VEXE} ${code_path} -o ${bin_path} -no-parallel'

enum ReleaseMode {
	release
	debug
	dev
}

fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

fn (m ReleaseMode) cc_flags() string {
	$if windows {
		return '-cc gcc' // TCC cannot build tree-sitter on Windows
	} $else $if cross_compile_macos_arm64 ? {
		return '-cc clang -cflags "-target arm64-apple-darwin"'
	} $else {
		return if m == .release { '-cc gcc' } else { '' }
	}
}

fn (m ReleaseMode) compile_cmd() string {
	libbacktrace := $if windows { '' } $else { '-d use_libbacktrace' }
	staticflags := $if linux { '-cflags -static' } $else { '' }
	return match m {
		.release { '${base_build_command} ${m.cc_flags()} ${staticflags} -prod' }
		.debug { '${base_build_command} ${m.cc_flags()} -g ${libbacktrace}' }
		.dev { '${base_build_command} ${m.cc_flags()} -d show_ast_on_hover -g ${libbacktrace}' }
	}
}

fn (m ReleaseMode) compile() os.Result {
	return os.execute(m.compile_cmd())
}

fn prepare_output_dir() {
	if os.exists('./bin') {
		return
	}
	os.mkdir('./bin') or { errorln('Failed to create output directory: ${err}') }
}

fn build(mode ReleaseMode, explicit_debug bool) {
	println('Building v-analyzer...')

	prepare_output_dir()
	println('${term.green('✓')} Prepared output directory')

	println('Building v-analyzer in ${term.bold(mode.str())} mode, using: ${mode.compile_cmd()}')
	if mode == .release {
		println('This may take a while...')
	}

	if !explicit_debug && mode == .debug {
		println('To build in ${term.bold('release')} mode, run ${term.bold('v build.vsh release')}')
		println('Release mode is recommended for production use. At runtime, it is about 30-40% faster than debug mode.')
	}

	res := mode.compile()
	if res.exit_code != 0 {
		errorln('Failed to build v-analyzer')
		eprintln(res.output)
		exit(1)
	}

	println('${term.green('✓')} Successfully built v-analyzer!')
	println('Binary is located at ${term.bold(abs_path(bin_path))}')
}

mut cmd := cli.Command{
	name: 'v-analyzer-builder'
	version: version
	description: 'Builds the v-analyzer binary.'
	posix_mode: true
	execute: fn (_ cli.Command) ! {
		build(.debug, false)
	}
}

// debug builds the v-analyzer binary in debug mode.
// This is the default mode.
// Thanks to -d use_libbacktrace, the binary will print beautiful stack traces,
// which is very useful for debugging.
cmd.add_command(cli.Command{
	name: 'debug'
	description: 'Builds the v-analyzer binary in debug mode.'
	execute: fn (_ cli.Command) ! {
		build(.debug, true)
	}
})

// dev builds the v-analyzer binary in development mode.
// In this mode, additional development features are enabled.
cmd.add_command(cli.Command{
	name: 'dev'
	description: 'Builds the v-analyzer binary in development mode.'
	execute: fn (_ cli.Command) ! {
		build(.dev, false)
	}
})

// release builds the v-analyzer binary in release mode.
// This is the recommended mode for production use.
// It is about 30-40% faster than debug mode.
cmd.add_command(cli.Command{
	name: 'release'
	description: 'Builds the v-analyzer binary in release mode.'
	execute: fn (_ cli.Command) ! {
		build(.release, false)
	}
})

cmd.parse(os.args)
