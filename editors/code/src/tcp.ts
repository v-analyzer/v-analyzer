import {StreamInfo} from "vscode-languageclient/node";
import * as net from "net";

export function connectAnalyzerViaTcp(port: number): Promise<StreamInfo> {
	const socket = net.connect({port});
	const result: StreamInfo = {
		writer: socket,
		reader: socket
	};
	return Promise.resolve(result);
}
