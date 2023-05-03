module utils

pub fn is_proc_exists(pid int) bool {
	return C.kill(pid, 0) == 0
}
