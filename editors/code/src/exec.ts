import {Terminal, window} from 'vscode';
import {getVExecCommand} from './utils';
import cp, {exec, ExecException} from 'child_process';

type ExecCallback = (error: ExecException | null, stdout: string, stderr: string) => void;

let runTerminal: Terminal = null;

function outputTerminal(): Terminal {
	if (!runTerminal) {
		runTerminal = window.createTerminal('V');
	}
	return runTerminal;
}

function buildCommand(args: string[]): string {
	const vexe = getVExecCommand();
	return `${vexe} ${args.join(' ')}`;
}

/**
 * Run V command in V terminal inside VS Code.
 */
export function runVCommand(args: string[]): void {
	const cmd = buildCommand(args);
	const term = outputTerminal();
	term.show();
	term.sendText(cmd);
}

/**
 * Run V command in background.
 */
export function runVCommandInBackground(args: string[]): void {
	const cmd = buildCommand(args);
	cp.exec(cmd);
}

/**
 * Run V command in background and call callback when done.
 */
export function runVCommandCallback(args: string[], callback: ExecCallback): void {
	const cmd = buildCommand(args);
	exec(cmd, callback);
}
