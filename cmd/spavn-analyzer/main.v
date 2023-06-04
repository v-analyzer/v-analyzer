module main

import os
import flag
import lserver
import jsonrpc
import streams
import analyzer
import term
import lsp.log

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	stdio := fp.bool('stdio', 0, false, 'Use stdio for communication')
	port := fp.int('port', 0, 5007, 'Port to use for socket communication. (Default: 5007)')

	mut stream := if stdio {
		streams.new_stdio_stream()
	} else {
		streams.new_socket_stream_server(port, true) or {
			println('${term.red('[ERROR]')} Cannot use ${port} for socket communication, try specify another port with --port')
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
