// MIT License
// 
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA vosca.dev)
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
import { Terminal, window } from "vscode";
import { getVExecCommand } from "./utils";
import cp, { exec, ExecException } from "child_process";

type ExecCallback = (error: ExecException | null, stdout: string, stderr: string) => void;

let runTerminal: Terminal = null!;

function outputTerminal(): Terminal {
	if (!runTerminal) {
		runTerminal = window.createTerminal("V");
	}
	return runTerminal;
}

function buildCommand(args: string[]): string {
	const vexe = getVExecCommand();
	return `${vexe} ${args.join(" ")}`;
}

/**
 * Run V command in V terminal inside VS Code.
 */
export function runVCommand(args: string[]): void {
	const cmd = buildCommand(args);
	const term = outputTerminal();
	term.show();
	term.sendText(cmd);
}

/**
 * Run V command in background.
 */
export function runVCommandInBackground(args: string[]): void {
	const cmd = buildCommand(args);
	cp.exec(cmd);
}

/**
 * Run V command in background and call callback when done.
 */
export function runVCommandCallback(args: string[], callback: ExecCallback): void {
	const cmd = buildCommand(args);
	exec(cmd, callback);
}
