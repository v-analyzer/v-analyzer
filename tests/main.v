module main

import os
import term
import strings

struct CompiledTest {
	name string
	res  os.Result
}

fn main() {
	tests := [
		'completion',
		'definitions',
		'implementations',
		'supers',
		'type_tests',
	]

	compiled_chan := chan CompiledTest{cap: 10}

	spawn fn [tests, compiled_chan] () {
		for test in tests {
			res := os.execute('${os.quoted_path(@VEXE)} ./${test}.v')

			compiled_chan <- CompiledTest{
				name: test
				res: res
			}
		}
		compiled_chan.close()
	}()

	mut failed := 0

	for {
		compiled := <-compiled_chan or { break }
		if compiled.res.exit_code != 0 {
			print(term.red('[ERROR] '))
			println('failed to compile ${compiled.name}')
			println(compiled.res.output)
			failed++
			continue
		}

		_, output := run_test(compiled.name) or {
			print(term.red('[ERROR] '))
			println('failed to run ${compiled.name}')
			println(err.str())
			failed++
			continue
		}

		println(output)
		println('')
		println(term.green('[OK] ') + compiled.name)
	}

	if failed > 0 {
		println(term.red('[ERROR] ${failed} tests failed'))
		exit(1)
	}

	println(term.green('[OK] all tests passed'))
}

fn run_test(name string) !(os.Command, string) {
	mut cmd := os.Command{
		eof: false
		exit_code: 0
		path: './${name}'
		redirect_stdout: false
	}

	cmd.start()!

	mut output := strings.new_builder(100)
	for !cmd.eof {
		output.write_string(cmd.read_line())
		output.write_string('\n')
	}

	cmd.close()!

	os.rm('./${name}')!

	if cmd.exit_code != 0 {
		return error('failed to run ${name}:\n${output.str()}')
	}

	return cmd, output.str().trim_right('\n')
}
