// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module loglib

import io
import time

@[inline]
pub fn log(level LogLevel, msg ...string) {
	logger.log(level, ...msg)
}

@[inline]
pub fn log_one(level LogLevel, msg string) {
	logger.log(level, msg)
}

@[inline]
pub fn warn(msg ...string) {
	logger.log(.warn, ...msg)
}

@[inline]
pub fn info(msg ...string) {
	logger.log(.info, ...msg)
}

@[inline]
pub fn trace(msg ...string) {
	logger.log(.trace, ...msg)
}

@[inline]
pub fn error(msg ...string) {
	logger.log(.error, ...msg)
}

@[inline]
pub fn set_level(level LogLevel) {
	logger.set_level(level)
}

@[inline]
pub fn set_flush_rate(dur time.Duration) {
	logger.flush_rate = dur
}

@[inline]
pub fn set_output(out io.Writer) {
	logger.set_output(out)
}

@[inline]
pub fn get_output() io.Writer {
	return logger.get_output()
}

@[inline]
pub fn with_fields(fields Fields) &Entry {
	return logger.with_fields(fields)
}

@[inline]
pub fn with_duration(dur time.Duration) &Entry {
	return logger.with_duration(dur)
}

@[inline]
pub fn with_gc_heap_usage(usage GCHeapUsage) &Entry {
	return logger.with_gc_heap_usage(usage)
}
