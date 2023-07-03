import * as vscode from 'vscode';
import * as commands from "./commands";
import {AnalyzerNotInstalledError, CommandFactory, Context, fetchWorkspace} from "./ctx";
import {WelcomePanel} from "./welcome";
import {setContextValue} from "./utils";
import {setGlobalState} from "./stateUtils";

const V_PROJECT_CONTEXT_NAME = "inVlangProject";

/**
 * This method is called when the extension is activated.
 * @param context The extension context
 */
export async function activate(context: vscode.ExtensionContext): Promise<Context> {
	if (vscode.extensions.getExtension("vlanguage.vscode-vlang")) {
		vscode.window
			.showWarningMessage(
				"You have both the v-analyzer and V plugins enabled." +
				"These are known to conflict and cause various functions of " +
				"both plugins to not work correctly. " +
				"v-analyzer provides all the features of the V plugin and more. " +
				"Disable the V plugin to avoid conflicts.",
				"Got it"
			)
			.then(() => {
			}, console.error);
	}

	const ctx = new Context(context, createCommands(), fetchWorkspace());
	setGlobalState(context.globalState);

	WelcomePanel.activate(ctx);

	const api = await activateServer(ctx).catch((err) => {
		if (!(err instanceof AnalyzerNotInstalledError)) {
			void vscode.window.showErrorMessage(
				`Cannot activate v-analyzer extension: ${err.message}`
			);
			throw err;
		}

		// If v-analyzer is not installed, we still want to activate the extension.
		return ctx;
	});

	// Set the context variable inVlangProject which can be referenced when configuring,
	// for example, shortcuts or other things in package.json.
	// See https://code.visualstudio.com/docs/getstarted/keybindings#_when-clause-contexts
	setContextValue(V_PROJECT_CONTEXT_NAME, true);

	return api;
}

export function deactivate(): void {
	setContextValue(V_PROJECT_CONTEXT_NAME, undefined);
}

async function activateServer(ctx: Context): Promise<Context> {
	vscode.workspace.onDidChangeConfiguration((e: vscode.ConfigurationChangeEvent) => {
		if (!e.affectsConfiguration('v-analyzer')) return;

		void vscode.window.showInformationMessage('v-analyzer: Restart is required for changes to take effect. Would you like to proceed?', 'Yes', 'No')
			.then(selected => {
				if (selected == 'Yes') {
					void vscode.commands.executeCommand('v-analyzer.restartServer');
				}
			});
	}, null, ctx.subscriptions);

	await ctx.start();
	return ctx;
}

function createCommands(): Record<string, CommandFactory> {
	return {
		restartServer: {
			enabled: (ctx) => async () => {
				await ctx.restart();
			},
			disabled: (ctx) => async () => {
				await ctx.start();
			},
		},
		startServer: {
			enabled: (ctx) => async () => {
				await ctx.start();
			},
			disabled: (ctx) => async () => {
				await ctx.start();
			},
		},
		stopServer: {
			enabled: (ctx) => async () => {
				await ctx.stopAndDispose();
				ctx.setServerStatus({
					health: "stopped",
				});
			},
			disabled: _ => async () => {
			},
		},
		runWorkspace: {enabled: commands.runWorkspace},
		runFile: {enabled: commands.runFile},
		runTests: {enabled: commands.runTests},
		version: {enabled: commands.version},
		serverVersion: {enabled: commands.serverVersion},
		showReferences: {enabled: commands.showReferences},
		viewStubTree: {enabled: commands.viewStubTree},
		uploadToPlayground: {enabled: commands.uploadToPlayground},
		showWelcome: {enabled: WelcomePanel.showWelcome, disabled: WelcomePanel.showWelcome},
		openGlobalConfig: {enabled: commands.openGlobalConfig, disabled: commands.openGlobalConfig},
	}
}
