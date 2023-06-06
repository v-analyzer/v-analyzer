module main

import os
import flag
import lserver
import jsonrpc
import streams
import analyzer
import cli
import lsp.log

const default_tcp_port = 5007

fn run(cmd cli.Command) ! {
	stdio := cmd.flags.get_bool('stdio') or { false }
	port := cmd.flags.get_int('port') or { default_tcp_port }

	mut stream := if stdio {
		streams.new_stdio_stream()
	} else {
		streams.new_socket_stream_server(port, true) or {
			errorln('Cannot use ${port} port for socket communication, try specify another port with --port')
			return
		}
	}

	mut ls := lserver.new(analyzer.new())
	mut jrpc_server := &jsonrpc.Server{
		stream: stream
		interceptors: [
			&log.LogRecorder{
				enabled: true
			},
		]
		handler: ls
	}

	jrpc_server.start()
}

fn main() {
	mut cmd := cli.Command{
		name: 'spavn-analyzer'
		version: '0.0.1-alpha'
		description: 'Language server implementation for V language'
		execute: run
		posix_mode: true
	}

	cmd.add_command(cli.Command{
		name: 'init'
		description: 'Initialize a configuration file inside the current directory.'
		execute: init_cmd
	})

	cmd.add_flags([
		cli.Flag{
			flag: .bool
			name: 'stdio'
			description: 'Use stdio for communication.'
		},
		cli.Flag{
			flag: .int
			name: 'port'
			description: 'Port to use for socket communication. (Default: 5007)'
			default_value: [
				'${default_tcp_port}',
			]
		},
	])

	cmd.parse(os.args)
}
