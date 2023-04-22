module main

import vex.server
import vex.ctx
import vex.router
import flag
import os
import time

// struct Analyzer {
// }

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	port := fp.int('port', `p`, 6790, 'port to listen on')
	// daemon_port := fp.int('daemon-port', `p`, 0, 'daemon port')

	spawn fn () {
		for i := 0; i < 5; i++ {
			println('sleeping')
			time.sleep(1 * time.second)
		}
		panic('just die')
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
