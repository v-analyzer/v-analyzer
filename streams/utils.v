module streams

import os

const content_length = 'Content-Length: '

fn make_lsp_payload(output string) string {
	return 'Content-Length: ${output.len}\r\n\r\n${output}'
}

fn new_vls_process(args ...string) &os.Process {
	mut p := os.new_process(os.executable())
	p.set_args(args)
	p.set_redirect_stdio()
	return p
}
