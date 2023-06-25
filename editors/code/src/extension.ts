import vscode, {ConfigurationChangeEvent, ExtensionContext, workspace} from 'vscode';
import * as commands from './commands';
import {activateVAnalyzer, deactivateVAnalyzer} from './langserver';

const cmds = {
	'v.run': commands.run,
	'v.fmt': commands.fmt,
	'v.ver': commands.ver,
	'v.prod': commands.prod,
	'v-analyzer.restart': commands.restartVAnalyzer,
	'v-analyzer.showReferences': commands.showReferences(),
};

/**
 * This method is called when the extension is activated.
 * @param context The extension context
 */
export function activate(context: ExtensionContext): void {
	for (const cmd in cmds) {
		const handler = cmds[cmd] as () => void;
		const disposable = vscode.commands.registerCommand(cmd, handler);
		context.subscriptions.push(disposable);
	}

	workspace.onDidChangeConfiguration((e: ConfigurationChangeEvent) => {
		if (!e.affectsConfiguration('v-analyzer')) return;

		void vscode.window.showInformationMessage('v-analyzer: Restart is required for changes to take effect. Would you like to proceed?', 'Yes', 'No')
			.then(selected => {
				if (selected == 'Yes') {
					void vscode.commands.executeCommand('v-analyzer.restart');
				}
			});
	});

	void activateVAnalyzer();
}

export function deactivate(): void {
	deactivateVAnalyzer();
}
