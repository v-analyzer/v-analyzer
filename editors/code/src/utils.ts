import * as vscode from 'vscode';

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
export function getWorkspaceConfig(): vscode.WorkspaceConfiguration {
	const currentWorkspaceFolder = getWorkspaceFolder();
	const uri = currentWorkspaceFolder ? currentWorkspaceFolder.uri : null;
	return vscode.workspace.getConfiguration('v-analyzer', uri);
}

/**
 * Get the workspace of a current document.
 * @param uri The URI of document
 */
export function getWorkspaceFolder(uri?: vscode.Uri): vscode.WorkspaceFolder {
	if (uri) {
		return vscode.workspace.getWorkspaceFolder(uri);
	}

	if (vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders.length > 0) {
		return vscode.workspace.workspaceFolders[0];
	}

	if (vscode.window.activeTextEditor && vscode.window.activeTextEditor.document) {
		return vscode.workspace.getWorkspaceFolder(vscode.window.activeTextEditor.document.uri);
	}

	return null
}

/**
 * Sets ['when'](https://code.visualstudio.com/docs/getstarted/keybindings#_when-clause-contexts)
 * clause contexts
 */
export function setContextValue(key: string, value: any): Thenable<void> {
	return vscode.commands.executeCommand("setContext", key, value);
}

export type VlangDocument = vscode.TextDocument & { languageId: "v" };
export type VlangEditor = vscode.TextEditor & { document: VlangDocument };

export function isVlangDocument(document: vscode.TextDocument): document is VlangDocument {
	return document.languageId === "v" && document.uri.scheme === "file";
}

export function isVlangEditor(editor: vscode.TextEditor): editor is VlangEditor {
	return isVlangDocument(editor.document);
}

export function sleep(ms: number) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}
