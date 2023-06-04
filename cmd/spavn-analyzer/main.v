module main

import os
import flag
import lserver
import jsonrpc
import streams
import analyzer
import lsp.log

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	stdio := fp.bool('stdio', 0, false, 'use stdio for communication')

	mut stream := if stdio {
		streams.new_stdio_stream()!
	} else {
		streams.new_socket_stream_server(5007, true)!
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
