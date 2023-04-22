module main

import vex.router
import vex.ctx
import vex.server
import os
import strconv
import net.http
import time
import log
import flag

const spavn_root = os.home_dir() + '/.spavn'

// RunInstance описывает запущенный экземпляр анализатора
struct RunInstance {
	id   int
	port int // порт на котором запущен анализатор
mut:
	cmd os.Command // команда через которую запущен анализатор
}

// DaemonState описывает состояние демона
struct DaemonState {
mut:
	instances_counter int  // счетчик запущенных экземпляров анализатора
	pause_checks      bool // флаг, который показывает нужно ли приостановить проверку экземпляров анализатора
	latest_port       int = 6790 // порт на котором запущен последний экземпляр анализатора
	instances         map[int]RunInstance // список запущенных экземпляров анализатора
}

struct Daemon {
mut:
	log   log.Log
	state &DaemonState
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	create_new := fp.bool('new', `n`, false, 'create new instance')

	mut daemon := Daemon{
		log: log.Log{}
		state: &DaemonState{
			instances: map[int]RunInstance{}
		}
	}

	daemon.log.set_output_label('spavn-daemon.log')
	daemon.log.set_output_path('.')
	daemon.log.log_to_console_too()
	daemon.log.set_level(.info)

	ensure_spavn_root_dir()
	if check_if_another_instance_is_running() {
		// Если уже запущен другой демон, то мы должны переадресовать ему запрос и завершить работу.

		daemon.log.info('another daemon is running, redirecting request to it')

		if create_new {
			// Если мы хотим создать новый экземпляр анализатора, то мы должны переадресовать запрос на создание экземпляра
			port := read_port() or {
				daemon.log.error('cannot get port of another instance')
				return
			}

			res := http.get('http://localhost:${port}/new') or {
				daemon.log.error('cannot get port of another instance')
				return
			}

			if res.status_code != 200 {
				daemon.log.error('cannot redirect request to another instance')
				return
			}
		}
		return
	}

	mut app := router.new()

	app.route(.get, '/', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_html('<p>Hello</p>', 200)
	})

	// /new создает новый экземпляр анализатора и возвращает порт на котором он запущен
	app.route(.get, '/new', fn [mut daemon] (_ &ctx.Req, mut res ctx.Resp) {
		port := daemon.run_analyzer()
		res.send_html(port.str(), 200)
	})

	app.route(.get, '/want_to_die', fn [mut daemon] (req &ctx.Req, mut res ctx.Resp) {
		daemon.state.pause_checks = true
		params := req.parse_query() or {
			map[string]string{}
		}
		id := params['id'] or {
			res.send_status(400)
			return
		}

		daemon.log.info('instance ${id} wants to die')
		daemon.state.instances.delete(id.int())
		daemon.log.info('instance ${id} is dead')
		res.send_status(200)
	})

	app.route(.get, '/alive', fn (_ &ctx.Req, mut res ctx.Resp) {
		res.send_status(200)
	})

	spawn fn [mut daemon] () {
		daemon.check_instances()
	}()

	write_port(6789)
	server.serve(app, 6789)
}

fn (mut d Daemon) run_analyzer() int {
	port := d.state.latest_port

	id := d.state.instances_counter
	mut cmd := os.Command{
		path: 'v run cmd/spavn-analyzer --port ${port} --daemon-port 6789 --id ${id}'
		redirect_stdout: false
	}

	cmd.start() or {
		println('cannot start analyzer')
		return 0
	}

	d.register_instance(port, cmd)

	d.state.latest_port++
	return port
}

fn (mut d Daemon) register_instance(port int, cmd os.Command) {
	time.sleep(1 * time.second)
	id := d.state.instances_counter

	d.log.info('new instance ${id} is running on port ${port}')

	d.state.instances[id] = RunInstance{
		id: id
		port: port
		cmd: cmd
	}

	d.state.instances_counter++
	d.state.pause_checks = true
}

fn (mut d Daemon) check_instances() {
	for {
		d.log.flush()

		if d.state.pause_checks {
			d.state.pause_checks = false
			time.sleep(2 * time.second)
			continue
		}

		mut instances_to_remove := []int{}
		for id, mut instance in d.state.instances {
			res := http.get('http://localhost:${instance.port}/alive') or {
				d.log.error('instance ${instance.id} is unexpectedly dead')
				instances_to_remove << instance.id
				d.show_info_about_failed_instance(mut instance)
				continue
			}
			if res.status_code != 200 {
				d.log.error('instance ${instance.id} is unexpectedly dead')
				instances_to_remove << instance.id
				d.show_info_about_failed_instance(mut instance)
				continue
			}

			d.log.info('instance ${instance.id} is alive')
		}

		for id in instances_to_remove {
			d.state.instances.delete(id)
		}

		if d.state.instances.len == 0 {
			// println('no instances')
		}

		time.sleep(1 * time.second)
	}
}

fn (mut d Daemon) show_info_about_failed_instance(mut instance RunInstance) {
	d.log.error('instance info:')
	d.log.error(instance.str())

	for !instance.cmd.eof {
		output := instance.cmd.read_line()
		d.log.error(output)
	}
}

// ensure_spavn_root_dir проверяет что папка с конфигурацией существует и
// создает ее если ее нет.
fn ensure_spavn_root_dir() {
	if !os.exists(spavn_root) {
		os.mkdir(spavn_root) or {
			println('cannot create spavn root directory')
			return
		}
	}
}

// write_port записывает порт на котором запущен демон в файл
fn write_port(port int) {
	mut f := os.create(spavn_root + '/port') or {
		println('cannot create port file')
		return
	}
	f.write_string(port.str()) or {
		println('cannot write port to file')
		return
	}
	f.close()
}

// read_port считывает порт на котором запущен демон из файла
fn read_port() ?int {
	port_string := os.read_file(spavn_root + '/port') or { return none }
	return strconv.atoi(port_string) or { return none }
}

// check_if_another_instance_is_running проверяет запущен ли уже другой демон
fn check_if_another_instance_is_running() bool {
	port := read_port() or { return false }
	res := http.get('http://localhost:${port}/alive') or { return false }
	return res.status_code == 200
}
