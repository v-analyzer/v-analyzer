import vscode from "vscode";

let globalState: vscode.Memento;

export function getFromGlobalState(key: string, defaultValue?: any): any {
	if (!globalState) {
		return defaultValue;
	}
	return globalState.get(key, defaultValue);
}

export function updateGlobalState(key: string, value: any) {
	if (!globalState) {
		return Promise.resolve();
	}
	return globalState.update(key, value);
}

export function setGlobalState(state: vscode.Memento) {
	globalState = state;
}
