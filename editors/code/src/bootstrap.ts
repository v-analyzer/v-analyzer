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
import cp from "child_process";
import os from "os";
import { log } from "./log";
import { getWorkspaceConfig } from "./utils";
import { AnalyzerNotInstalledError } from "./ctx";

/**
 * bootstrap returns the path to the v-analyzer binary.
 * It will throw an error if the binary is not available.
 *
 * @returns {Promise<string>} The path to the v-analyzer binary.
 */
export async function bootstrap(): Promise<string> {
	const path = getAnalyzerPath();

	if (!isAnalyzerExecutableValid(path)) {
		const config = getWorkspaceConfig();
		const explicitPath = config.get<string>("serverPath");
		if (explicitPath) {
			throw new Error(`Failed to execute ${path} -v. \`config.serverPath\`has been set explicitly.\
            Consider removing this config or making a valid server binary available at that path.`);
		}

		throw new AnalyzerNotInstalledError(
			`Failed to execute ${path} -v, make sure the v-analyzer is installed and available in the PATH`,
		);
	}

	log.info("Using server binary at", path);

	return path;
}

function getAnalyzerPath(): string {
	const config = getWorkspaceConfig();
	const explicitPath = config.get<string>("serverPath");
	const path = explicitPath ? explicitPath : "v-analyzer";

	if (path.startsWith("~/") || path.startsWith("~\\")) {
		return path.replace("~", os.homedir());
	}

	return path;
}

function isAnalyzerExecutableValid(path: string): boolean {
	const location = path === "v-analyzer" ? "PATH" : path;
	log.debug("Checking availability of a binary at", location);
	const res = cp.spawnSync(`${path}`, ["-v"]);
	return res.status === 0;
}
