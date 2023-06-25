import {getWorkspaceConfig} from "./utils";
import cp from "child_process";
import {log} from "./log";

/**
 * bootstrap returns the path to the v-analyzer binary.
 * It will throw an error if the binary is not available.
 *
 * @returns {Promise<string>} The path to the v-analyzer binary.
 */
export async function bootstrap(): Promise<string> {
	const path = getAnalyzerPath();
	if (!path) {
		throw new Error("v-analyzer binary is not available, make sure the v-analyzer is installed and available in the PATH");
	}

	log.info("Using server binary at", path);

	if (!isAnalyzerExecutableValid(path)) {
		const config = getWorkspaceConfig();
		const explicitPath = config.get<string>('serverPath');
		if (explicitPath) {
			throw new Error(`Failed to execute ${path} -v. \`config.serverPath\`has been set explicitly.\
            Consider removing this config or making a valid server binary available at that path.`);
		}

		throw new Error(`Failed to execute ${path} -v, make sure the v-analyzer is installed and available in the PATH`);
	}

	return path;
}

function getAnalyzerPath(): string {
	const config = getWorkspaceConfig();
	const explicitPath = config.get<string>('serverPath');
	return explicitPath ? explicitPath : 'v-analyzer';
}

function isAnalyzerExecutableValid(path: string): boolean {
	const location = path === 'v-analyzer' ? 'PATH' : path;
	log.debug("Checking availability of a binary at", location);
	const res = cp.spawnSync(`${path}`, ['-v']);
	return res.status === 0;
}
