module main

import vex.server as vserver
import vex.ctx
import vex.router
import flag
import os
import net.http
import lserver
import jsonrpc
import lsp.log
import analyzer

struct Analyzer {
	id          int
	port        int
	daemon_port int
}

fn (a &Analyzer) want_die() {
	url := 'http://localhost:${a.daemon_port}/want_to_die?id=${a.id}'
	println(url)
	res := http.get(url) or {
		println('failed to send die request to daemon, err: ${err}')
		exit(0)
		return
	}

	if res.status_code != 200 {
		println('failed to send die request to daemon')
		exit(0)
		return
	}
	exit(0)
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	stdin := fp.bool('stdin', 0, false, 'use stdin')
	// id := fp.int('id', 0, 6790, 'id of analyzer')
	// port := fp.int('port', `p`, 6790, 'port to listen on')
	// daemon_port := fp.int('daemon-port', 0, 0, 'daemon port')

	// spawn run_server(id, port, daemon_port)

	analyzer_instance := analyzer.new()

	// mut stream := new_stdio_stream()!
	mut stream := if stdin { new_stdio_stream()! } else { new_socket_stream_server(5007, true)! }

	mut ls := lserver.new(analyzer_instance)
	mut jrpc_server := &jsonrpc.Server{
		stream: stream
		interceptors: [
			&log.LogRecorder{
				enabled: true
			},
		]
		handler: ls
	}

	mut rw := unsafe { &lserver.ResponseWriter(jrpc_server.writer(own_buffer: true)) }

	// spawn lserver.monitor_changes(mut ls, mut rw)
	jrpc_server.start()
}

fn run_server(id int, port int, daemon_port int) {
	mut app := router.new()

	app.route(.get, '/', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_html('<p>Hello Analyzer</p>', 200)
	})

	app.route(.get, '/alive', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_status(200)
	})

	vserver.serve(app, port)
}
