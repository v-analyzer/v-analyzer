import { window } from 'vscode';

export const vOutputChannel = window.createOutputChannel('V');
export const spavnAnalyzerOutputChannel = window.createOutputChannel('spavn-analyzer');

export function log(msg: string): void {
    // logging for devtools/debug
    console.log(`[spavn-analyzer] ${msg}`);
    vOutputChannel.appendLine(msg);
}
