module main

import term

pub fn errorln(msg string) {
	eprintln('${term.red('[ERROR]')} ${msg}')
}

pub fn warnln(msg string) {
	println('${term.yellow('[WARN]')} ${msg}')
}

pub fn infoln(msg string) {
	println('${term.blue('[INFO]')} ${msg}')
}

pub fn successln(msg string) {
	println('${term.green('[SUCCESS]')} ${msg}')
}
