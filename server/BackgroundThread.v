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
module server

import time
import loglib

type Task = fn ()

enum BackgroundThreadState {
	stopped
	running
}

// BackgroundThread is a simple abstraction a system thread.
// It accepts tasks and executes them in FIFO order.
//
// By executing tasks in a separate thread, we can perform long
// operations without blocking the main thread.
struct BackgroundThread {
	end_ch  chan bool
	task_ch chan Task = chan Task{cap: 20}
mut:
	state BackgroundThreadState
}

// start starts a background thread.
pub fn (mut b BackgroundThread) start() {
	spawn fn [mut b] () {
		b.state = .running
		for {
			select {
				task := <-b.task_ch {
					task()
				}
				_ := <-b.end_ch {
					return
				}
				100 * time.second {
					// wait
				}
			}
		}
	}()
}

// stop stops a background thread.
pub fn (b &BackgroundThread) stop() {
	if b.state == .stopped {
		loglib.warn('Cannot end stopped background thread')
		return
	}

	b.end_ch <- true
}

// queue queues a task to a background thread.
// Tasks will be executed in FIFO order.
pub fn (b &BackgroundThread) queue(cb fn ()) {
	if b.state == .stopped {
		loglib.warn('Cannot queue task to stopped background thread')
		return
	}

	b.task_ch <- cb
}
