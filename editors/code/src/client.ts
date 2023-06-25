import * as lc from "vscode-languageclient/node";
import vscode, {window, workspace} from "vscode";

let crashCount = 0;

export async function createClient(
	outputChannel: vscode.OutputChannel,
	serverOptions: lc.ServerOptions,
): Promise<lc.LanguageClient> {
	const clientOptions: lc.LanguageClientOptions = {
		documentSelector: [{scheme: 'file', language: 'v'}],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.v')
		},
		outputChannel: outputChannel,
		errorHandler: {
			error: (error: Error, _: lc.Message, count: number) => {
				// taken from: https://github.com/golang/vscode-go/blob/HEAD/src/goLanguageServer.ts#L533-L539
				if (count < 5) {
					return {
						message: '', // suppresses error popups
						action: lc.ErrorAction.Continue
					};
				}
				void window.showErrorMessage(
					`v-analyzer: Error communicating with the language server: ${error}: ${error}.`
				);

				return {
					action: lc.ErrorAction.Shutdown
				};
			},
			closed: () => {
				crashCount++;
				if (crashCount < 5) {
					return {
						message: '', // suppresses error popups
						action: lc.CloseAction.Restart
					};
				}
				return {
					action: lc.CloseAction.DoNotRestart
				};
			},
		},
		markdown: {
			isTrusted: true,
			supportHtml: true
		}
	};

	const client = new lc.LanguageClient(
		'v-analyzer',
		'V Language Server',
		serverOptions,
		clientOptions,
		true
	);

	client.registerFeature(new ExperimentalFeatures());

	return client;
}

class ExperimentalFeatures implements lc.StaticFeature {
	getState(): lc.FeatureState {
		return {kind: "static"};
	}

	fillClientCapabilities(capabilities: lc.ClientCapabilities): void {
		capabilities.experimental = {
			serverStatusNotification: true,
			viewStubTree: true,
			...capabilities.experimental,
		};
	}

	initialize(
		_capabilities: lc.ServerCapabilities,
		_documentSelector: lc.DocumentSelector | undefined
	): void {
	}

	dispose(): void {
	}
}
