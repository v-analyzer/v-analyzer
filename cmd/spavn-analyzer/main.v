module main

import vex.server
import vex.ctx
import vex.router
import flag
import os
import time
import net.http

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
	id := fp.int('id', 0, 6790, 'id of analyzer')
	port := fp.int('port', `p`, 6790, 'port to listen on')
	daemon_port := fp.int('daemon-port', 0, 0, 'daemon port')

	analyzer := Analyzer{
		id: id
		port: port
		daemon_port: daemon_port
	}

	spawn fn [analyzer] () {
		for i := 0; i < 5; i++ {
			println('sleeping')
			time.sleep(1 * time.second)
		}
		analyzer.want_die()
	}()

	mut app := router.new()

	app.route(.get, '/', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_html('<p>Hello Analyzer</p>', 200)
	})

	app.route(.get, '/alive', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_status(200)
	})

	server.serve(app, port)
}
