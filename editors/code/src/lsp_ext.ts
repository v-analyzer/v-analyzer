import * as lc from "vscode-languageclient";

export const serverStatus = new lc.NotificationType<ServerStatusParams>(
	"experimental/serverStatus"
);

export type ServerStatusParams = {
	health: "ok" | "warning" | "error";
	quiescent: boolean;
	message?: string;
};

export const viewStubTree = new lc.RequestType<lc.TextDocumentIdentifier, string, void>(
	"v-analyzer/viewStubTree"
);
