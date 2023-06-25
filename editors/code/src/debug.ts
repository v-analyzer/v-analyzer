import { window } from 'vscode';

export const vOutputChannel = window.createOutputChannel('V');
export const vAnalyzerOutputChannel = window.createOutputChannel('v-analyzer');

export function log(msg: string): void {
    // logging for devtools/debug
    console.log(`[v-analyzer] ${msg}`);
    vOutputChannel.appendLine(msg);
}
