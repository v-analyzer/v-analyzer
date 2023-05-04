module lserver

import jsonrpc

pub type ResponseWriter = jsonrpc.ResponseWriter

fn (mut wr ResponseWriter) wrap_error(err IError) IError {
	if err is none {
		wr.write(jsonrpc.null)
		return err
	}
	wr.log_message(err.msg(), .error)
	return none
}
