import {ProgressLocation, window} from 'vscode';
import {runVCommand, runVCommandCallback, runVCommandInBackground} from './exec';
import {activateSpavnAnalyzer, client, deactivateSpavnAnalyzer} from './langserver';
import {log, spavnAnalyzerOutputChannel, vOutputChannel} from './debug';
import * as path from "path";
import vscode from "vscode";
import * as lc from "vscode-languageclient";

/**
 * Run current directory.
 */
export async function run(): Promise<void> {
	const document = window.activeTextEditor.document;
	await document.save();
	const dir = path.parse(document.fileName).dir

	runVCommand(['run', dir]);
}

/**
 * Format current file.
 */
export async function fmt(): Promise<void> {
	const document = window.activeTextEditor.document;
	await document.save();
	const filePath = `"${document.fileName}"`;

	runVCommandInBackground(['fmt', '-w', filePath]);
}

/**
 * Build an optimized executable from current file.
 */
export async function prod(): Promise<void> {
	const document = window.activeTextEditor.document;
	await document.save();
	const filePath = `"${document.fileName}"`;

	runVCommand(['-prod', filePath]);
}

/**
 * Show version info.
 */
export function ver(): void {
	runVCommandCallback(['-version'], (err, stdout) => {
		if (err) {
			void window.showErrorMessage(
				'Unable to get the version number. Is V installed correctly?'
			);
			return;
		}
		void window.showInformationMessage(stdout);
	});
}

export function restartSpavnAnalyzer(): void {
	window.withProgress({
		location: ProgressLocation.Notification,
		cancellable: false,
		title: 'spavn-analyzer'
	}, async (progress) => {
		progress.report({message: 'Restarting'});
		deactivateSpavnAnalyzer();
		spavnAnalyzerOutputChannel.clear();
		await activateSpavnAnalyzer();
	}).then(
		() => {
			return;
		},
		(err) => {
			log(err);
			vOutputChannel.show();
			void window.showErrorMessage(
				'Failed restarting spavn-analyzer. See output for more information.'
			);
		}
	);
}

export type Cmd = (...args: any[]) => unknown;

export function showReferences(): Cmd {
	return async (uri: string, positionData: string, locationData: string) => {
		const locations = JSON.parse(locationData);
		const position = JSON.parse(positionData);
		await showReferencesImpl(uri, position, locations);
	};
}

export async function showReferencesImpl(
	uri: string,
	position: lc.Position,
	locations: lc.Location[]
) {
	if (client) {
		console.log(vscode.Uri.parse(uri))
		console.log(position)
		console.log(client.protocol2CodeConverter.asPosition(position))
		console.log(locations.map(client.protocol2CodeConverter.asLocation))

		await vscode.commands.executeCommand(
			"editor.action.showReferences",
			vscode.Uri.parse(uri),
			client.protocol2CodeConverter.asPosition(position),
			locations.map(client.protocol2CodeConverter.asLocation)
		);
	}
}
