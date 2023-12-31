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
import * as lc from "vscode-languageclient/node";
import vscode, { window, workspace } from "vscode";

let crashCount = 0;

export async function createClient(
	outputChannel: vscode.OutputChannel,
	serverOptions: lc.ServerOptions,
): Promise<lc.LanguageClient> {
	const clientOptions: lc.LanguageClientOptions = {
		documentSelector: [{ scheme: "file", language: "v" }],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher("**/*.v"),
		},
		outputChannel: outputChannel,
		errorHandler: {
			error: (error: Error, _: lc.Message, count: number) => {
				// taken from: https://github.com/golang/vscode-go/blob/HEAD/src/goLanguageServer.ts#L533-L539
				if (count < 5) {
					return {
						message: "", // suppresses error popups
						action: lc.ErrorAction.Continue,
					};
				}
				void window.showErrorMessage(
					`v-analyzer: Error communicating with the language server: ${error}: ${error}.`,
				);

				return {
					action: lc.ErrorAction.Shutdown,
				};
			},
			closed: () => {
				crashCount++;
				if (crashCount < 5) {
					return {
						message: "", // suppresses error popups
						action: lc.CloseAction.Restart,
					};
				}
				return {
					action: lc.CloseAction.DoNotRestart,
				};
			},
		},
		markdown: {
			isTrusted: true,
			supportHtml: true,
		},
	};

	const client = new lc.LanguageClient(
		"v-analyzer",
		"V Language Server",
		serverOptions,
		clientOptions,
		true,
	);

	client.registerFeature(new ExperimentalFeatures());

	return client;
}

class ExperimentalFeatures implements lc.StaticFeature {
	fillInitializeParams?: (params: lc.InitializeParams) => void;
	preInitialize?: (
		capabilities: lc.ServerCapabilities<any>,
		documentSelector: lc.DocumentSelector,
	) => void;
	clear(): void {}
	getState(): lc.FeatureState {
		return { kind: "static" };
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
		_documentSelector: lc.DocumentSelector | undefined,
	): void {}

	dispose(): void {}
}
