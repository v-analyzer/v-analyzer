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
import {log, vAnalyzerOutputChannel} from './debug';
import {Message} from "vscode-languageclient";

export let client: LanguageClient;

let crashCount = 0;
let vAnalyzerProcess: cp.ChildProcess;

export async function checkVAnalyzerInstallation(): Promise<boolean> {
	const useRemoteServer = getWorkspaceConfig().get<boolean>('tcpMode.useRemoteServer');
	// if we use remote server, we don't need to check v-analyzer installation
	if (useRemoteServer) {
		return true;
	}

	const installed = isVAnalyzerInstall();
	if (!installed) {
		await window.showInformationMessage('Cannot find v-analyzer in PATH. Please install it and restart VS Code.');
	}
	return true;
}

function findVAnalyzerPath(): string {
	const config = getWorkspaceConfig();
	const customPath = config.get<string>('customPath');
	return customPath ? customPath : 'v-analyzer';
}

function isVAnalyzerInstall(): boolean {
	const path = findVAnalyzerPath();
	log(path);
	const res = cp.spawnSync(`${path}`, ['-v']);
	return res.status === 0;
}

function runVAnalyzer(args: string[]): cp.ChildProcess {
	const analyzerPath = findVAnalyzerPath();
	log(`Spawning ${analyzerPath} ${args.join(' ')}...`);
	const folder = getWorkspaceFolder();
	return cp.spawn(analyzerPath, args, {shell: true, cwd: folder.uri.fsPath});
}

function connectVAnalyzerViaTcp(port: number): Promise<StreamInfo> {
	const socket = net.connect({port});
	const result: StreamInfo = {
		writer: socket,
		reader: socket
	};
	return Promise.resolve(result);
}

export function connectVAnalyzer(): void {
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

	killVAnalyzerProcess();

	if (shouldSpawnProcess) {
		vAnalyzerProcess = runVAnalyzer(args);
	}

	const serverOptions: ServerOptions = connMode == 'tcp'
		? () => connectVAnalyzerViaTcp(tcpPort)
		: () => Promise.resolve(vAnalyzerProcess);

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{scheme: 'file', language: 'v'}],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.v')
		},
		outputChannel: vAnalyzerOutputChannel,
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
					`v-analyzer: Error communicating with the language server: ${error}: ${error}.`
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
		window.showWarningMessage(`v-analyzer failed to initialize: ${reason}`);
		client = null;
	}).then(() => {
		window.setStatusBarMessage('v-analyzer is ready.', 3000);
	});
}

export async function activateVAnalyzer(): Promise<void> {
	const installed = await checkVAnalyzerInstallation();
	if (!installed) {
		return;
	}

	connectVAnalyzer();
}

export function deactivateVAnalyzer(): void {
	killVAnalyzerProcess();
}

function killVAnalyzerProcess(): void {
	if (!vAnalyzerProcess || vAnalyzerProcess.killed) {
		return;
	}

	log('Terminating existing v-analyzer process.');
	vAnalyzerProcess.kill("SIGKILL")
}
