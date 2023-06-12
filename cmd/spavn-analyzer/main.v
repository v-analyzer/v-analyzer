module main

import server
import jsonrpc
import streams
import analyzer
import cli
import os
import loglib
import time
import config
import lsp.log

// default_tcp_port is default TCP port that the analyzer uses to connect to the socket
// when the --socket flag is passed at startup.
// See also the `--port` flag to specify a custom port.
const default_tcp_port = 5007

fn run(cmd cli.Command) ! {
	stdio := cmd.flags.get_bool('stdio') or { true }
	socket := cmd.flags.get_bool('socket') or { false }
	port := cmd.flags.get_int('port') or { default_tcp_port }

	mut stream := if socket {
		streams.new_socket_stream_server(port, true) or {
			errorln('Cannot use ${port} port for socket communication, try specify another port with --port')
			return
		}
	} else if stdio {
		streams.new_stdio_stream()
	} else {
		errorln('Either --stdio or --socket flag must be specified')
		return
	}

	setup_logger(stdio && !socket)

	mut ls := server.new(analyzer.new())
	mut jrpc_server := &jsonrpc.Server{
		stream: stream
		interceptors: [
			&log.LogRecorder{
				enabled: true
			},
		]
		handler: ls
	}

	defer {
		mut out := loglib.get_output()
		if mut out is os.File {
			out.close()
		}
	}

	jrpc_server.start()
}

fn setup_logger(to_file bool) {
	if to_file {
		if !os.exists(config.analyzer_logs_path) {
			os.mkdir_all(config.analyzer_logs_path) or {
				errorln('Failed to create analyzer logs directory: ${err}')
				return
			}
		}

		config_path := os.join_path(config.analyzer_logs_path, config.analyzer_log_file_name)

		if mut file := os.open_file(config_path, 'a') {
			loglib.set_output(file)
		}
	}

	loglib.set_level(.trace)
	loglib.set_flush_rate(1 * time.second)
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
			default_value: [
				'true',
			]
		},
		cli.Flag{
			flag: .bool
			name: 'socket'
			description: 'Use TCP connection for communication.'
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
