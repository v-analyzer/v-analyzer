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
import vscode from "vscode";
import { inspect } from "util";

export const log = new (class {
	private enabled = true;
	private readonly output = vscode.window.createOutputChannel("V Analyzer Client");

	setEnabled(yes: boolean): void {
		log.enabled = yes;
	}

	// Hint: the type [T, ...T[]] means a non-empty array
	debug(...msg: [unknown, ...unknown[]]): void {
		if (!log.enabled) return;
		log.write("DEBUG", ...msg);
	}

	info(...msg: [unknown, ...unknown[]]): void {
		log.write("INFO", ...msg);
	}

	warn(...msg: [unknown, ...unknown[]]): void {
		debugger;
		log.write("WARN", ...msg);
	}

	error(...msg: [unknown, ...unknown[]]): void {
		debugger;
		log.write("ERROR", ...msg);
		log.output.show(true);
	}

	private write(label: string, ...messageParts: unknown[]): void {
		const message = messageParts.map(log.stringify).join(" ");
		const dateTime = new Date().toLocaleString();
		log.output.appendLine(`${label} [${dateTime}]: ${message}`);
	}

	private stringify(val: unknown): string {
		if (typeof val === "string") return val;
		return inspect(val, {
			colors: false,
			depth: 6, // heuristic
		});
	}
})();
