import cp from 'child_process';
import * as net from 'net';
import {window, workspace} from 'vscode';
import {
	CloseAction,
	ErrorAction,
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
	StreamInfo
} from 'vscode-languageclient/node';

import {getWorkspaceConfig, getWorkspaceFolder} from './utils';
import {log, spavnAnalyzerOutputChannel} from './debug';
import {Message} from "vscode-languageclient";

export let client: LanguageClient;

let crashCount = 0;
let spavnAnalyzerProcess: cp.ChildProcess;

export async function checkSpavnAnalyzerInstallation(): Promise<boolean> {
	const useRemoteServer = getWorkspaceConfig().get<boolean>('tcpMode.useRemoteServer');
	// if we use remote server, we don't need to check spavn-analyzer installation
	if (useRemoteServer) {
		return true;
	}

	const installed = isSpavnAnalyzerInstall();
	if (!installed) {
		await window.showInformationMessage('Cannot find spavn-analyzer in PATH. Please install it and restart VS Code.');
	}
	return true;
}

function findSpavnAnalyzerPath(): string {
	const config = getWorkspaceConfig();
	const customPath = config.get<string>('customPath');
	return customPath ? customPath : 'spavn-analyzer';
}

function isSpavnAnalyzerInstall(): boolean {
	const path = findSpavnAnalyzerPath();
	log(path);
	const res = cp.spawnSync(`${path}`, ['-v']);
	return res.status === 0;
}

function runSpavnAnalyzer(args: string[]): cp.ChildProcess {
	const analyzerPath = findSpavnAnalyzerPath();
	log(`Spawning ${analyzerPath} ${args.join(' ')}...`);
	const folder = getWorkspaceFolder();
	return cp.spawn(analyzerPath, args, {shell: true, cwd: folder.uri.path});
}

function connectSpavnAnalyzerViaTcp(port: number): Promise<StreamInfo> {
	const socket = net.connect({port});
	const result: StreamInfo = {
		writer: socket,
		reader: socket
	};
	return Promise.resolve(result);
}

export function connectSpavnAnalyzer(): void {
	let shouldSpawnProcess = true;

	const config = getWorkspaceConfig();

	const connMode = config.get<string>('connectionMode');
	const tcpPort = config.get<number>('tcpMode.port');

	const customArgsString = config.get<string>('customArgs') ?? '';
	const args: string[] = customArgsString.split(' ').filter(Boolean);

	if (connMode == 'tcp') {
		args.push('--socket', '--port', tcpPort.toString());

		if (config.get<boolean>('tcpMode.useRemoteServer')) {
			shouldSpawnProcess = false;
		}
	} else {
		args.push('--stdio');
	}

	killSpavnAnalyzerProcess();

	if (shouldSpawnProcess) {
		spavnAnalyzerProcess = runSpavnAnalyzer(args);
	}

	const serverOptions: ServerOptions = connMode == 'tcp'
		? () => connectSpavnAnalyzerViaTcp(tcpPort)
		: () => Promise.resolve(spavnAnalyzerProcess);

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{scheme: 'file', language: 'v'}],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.v')
		},
		outputChannel: spavnAnalyzerOutputChannel,
		errorHandler: {
			error: (error: Error, _: Message, count: number) => {
				// taken from: https://github.com/golang/vscode-go/blob/HEAD/src/goLanguageServer.ts#L533-L539
				if (count < 5) {
					return {
						message: '', // suppresses error popups
						action: ErrorAction.Continue
					};
				}
				void window.showErrorMessage(
					// eslint-disable-next-line @typescript-eslint/restrict-template-expressions
					`spavn-analyzer: Error communicating with the language server: ${error}: ${error}.`
				);

				return {
					action: ErrorAction.Shutdown
				};
			},
			closed: () => {
				crashCount++;
				if (crashCount < 5) {
					return {
						message: '', // suppresses error popups
						action: CloseAction.Restart
					};
				}
				return {
					action: CloseAction.DoNotRestart
				};
			},
		},
		markdown: {
			isTrusted: true
		}
	};

	client = new LanguageClient(
		'V Language Server',
		serverOptions,
		clientOptions,
		true
	);

	client.start().catch(reason => {
		window.showWarningMessage(`spavn-analyzer failed to initialize: ${reason}`);
		client = null;
	}).then(() => {
		window.setStatusBarMessage('spavn-analyzer is ready.', 3000);
	});
}

export async function activateSpavnAnalyzer(): Promise<void> {
	const installed = await checkSpavnAnalyzerInstallation();
	if (!installed) {
		return;
	}

	connectSpavnAnalyzer();
}

export function deactivateSpavnAnalyzer(): void {
	killSpavnAnalyzerProcess();
}

function killSpavnAnalyzerProcess(): void {
	if (!spavnAnalyzerProcess || spavnAnalyzerProcess.killed) {
		return;
	}

	log('Terminating existing spavn-analyzer process.');
	spavnAnalyzerProcess.kill("SIGKILL")
}
