// This script is used to build the v-analyzer binary.
//
// Usage:
//  v build.vsh [debug|dev|release]
//
// By default, used debug mode.
import os
import cli
import term

pub const (
	code_path          = './cmd/v-analyzer'
	bin_path           = './bin/v-analyzer' + $if windows {
		'.exe'
	} $else {
		''
	}
	base_build_command = '${@VEXE} ${code_path} -o ${bin_path}'
	compiler_flag      = $if windows {
		'-cc gcc' // TCC cannot build tree-sitter on Windows
	} $else $if cross_compile_macos_arm64 ? {
		'-cc clang -cflags "-target arm64-apple-darwin"'
	} $else {
		''
	}
)

enum ReleaseMode {
	release
	debug
	dev
}

fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

fn (m ReleaseMode) compile() os.Result {
	libbacktrace := $if windows { '' } $else { '-d use_libbacktrace' }
	return match m {
		.release { os.execute('${base_build_command} ${compiler_flag} -w -prod') }
		.debug { os.execute('${base_build_command} ${compiler_flag} -g ${libbacktrace}') }
		.dev { os.execute('${base_build_command} ${compiler_flag} -d show_ast_on_hover -g ${libbacktrace}') }
	}
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

	println('Building v-analyzer in ${term.bold(mode.str())} mode...')
	if mode == .release {
		println('This may take a while...')
	}

	if !explicit_debug && mode == .debug {
		println('To build in ${term.bold('release')} mode, run ${term.bold('v build.vsh release')}')
		println('Release mode is recommended for production use. It is about 30-40% faster than debug mode.')
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
	version: '0.0.1-beta.1'
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
