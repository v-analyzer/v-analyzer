import {Uri, window, workspace, WorkspaceConfiguration, WorkspaceFolder} from 'vscode';

/**
 * Get V executable command.
 * Will get from user setting configuration first.
 * If user don't specify it, then get default command
 */
export function getVExecCommand(): string {
	const config = getWorkspaceConfig();
	return config.get('v.executablePath', 'v');
}

/**
 * Get v-analyzer configuration.
 */
export function getWorkspaceConfig(): WorkspaceConfiguration {
	const currentWorkspaceFolder = getWorkspaceFolder();
	return workspace.getConfiguration('v-analyzer', currentWorkspaceFolder.uri);
}

/** Get workspace of current document.
 * @param uri The URI of document
 */
export function getWorkspaceFolder(uri?: Uri): WorkspaceFolder {
	if (uri) {
		return workspace.getWorkspaceFolder(uri);
	} else if (window.activeTextEditor && window.activeTextEditor.document) {
		return workspace.getWorkspaceFolder(window.activeTextEditor.document.uri);
	} else {
		return workspace.workspaceFolders[0];
	}
}
