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
import * as vscode from "vscode";

/**
 * Get V executable command.
 * Will get from user setting configuration first.
 * If user don't specify it, then get default command
 */
export function getVExecCommand(): string {
	const config = getWorkspaceConfig();
	return config.get("v.executablePath", "v");
}

/**
 * Get v-analyzer configuration.
 */
export function getWorkspaceConfig(): vscode.WorkspaceConfiguration {
	const currentWorkspaceFolder = getWorkspaceFolder();
	const uri = currentWorkspaceFolder ? currentWorkspaceFolder.uri : null;
	return vscode.workspace.getConfiguration("v-analyzer", uri);
}

/**
 * Get the workspace of a current document.
 * @param uri The URI of document
 */
export function getWorkspaceFolder(uri?: vscode.Uri): vscode.WorkspaceFolder {
	if (uri) {
		return vscode.workspace.getWorkspaceFolder(uri)!;
	}

	if (
		vscode.workspace.workspaceFolders &&
		vscode.workspace.workspaceFolders.length > 0
	) {
		return vscode.workspace.workspaceFolders[0];
	}

	if (vscode.window.activeTextEditor && vscode.window.activeTextEditor.document) {
		return vscode.workspace.getWorkspaceFolder(
			vscode.window.activeTextEditor.document.uri,
		)!;
	}

	return null!;
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

export function isVlangDocument(
	document: vscode.TextDocument,
): document is VlangDocument {
	return document.languageId === "v" && document.uri.scheme === "file";
}

export function isVlangEditor(editor: vscode.TextEditor): editor is VlangEditor {
	return isVlangDocument(editor.document);
}

export function sleep(ms: number) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}
