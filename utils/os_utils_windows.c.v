module utils

fn C.OpenProcess(access int, inherit_handle bool, pid int) C.HANDLE

pub fn is_proc_exists(pid int) bool {
	exit_code := u32(0)
	got_process := C.OpenProcess(0x0400, false, pid)
	C.GetExitCodeProcess(got_process, voidptr(&exit_code))
	return exit_code == C.STILL_ACTIVE
}
