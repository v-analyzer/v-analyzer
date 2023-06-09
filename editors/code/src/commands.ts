import { window, ProgressLocation } from 'vscode';
import { runVCommand, runVCommandInBackground, runVCommandCallback } from './exec';
import { activateSpavnAnalyzer, deactivateSpavnAnalyzer } from './langserver';
import { log, vOutputChannel, spavnAnalyzerOutputChannel } from './debug';
import * as path from "path";

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
		progress.report({ message: 'Restarting' });
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
