# v-analyzer support for Visual Studio Code

[![VSCode Extension](https://img.shields.io/badge/VS_Code-extension-25829e?logo=visualstudiocode&logoWidth=10)](https://marketplace.visualstudio.com/items?itemName=VOSCA.vscode-v-analyzer)
[![VS Code extension tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml)

Provides
[V programming language](https://vlang.io)
and
[`v-analyzer`](https://github.com/v-analyzer/v-analyzer)
support for Visual Studio Code.
It is recommended over and replaces
[V extension](https://marketplace.visualstudio.com/items?itemName=vlanguage.vscode-vlang).

## Features

- syntax highlighting
- code completion
- go to definition, type definition
- find all references, document symbol, symbol renaming
- types and documentation on hover
- inlay hints for types and some construction like `or` block
- semantic syntax highlighting
- formatting
- signature help

## Usage

1. Install Visual Studio Code >= `1.66.0`.
2. Open the command palette with `Ctrl+Shift+P` or `Cmd+Shift+P`
3. Select `Install Extensions` and choose `v-analyzer`.
4. Open a `.v` file and start coding!

## Manual installation

1. Open the command palette with `Ctrl+Shift+P` or `Cmd+Shift+P`
2. Type `Install from VSIX...` and hit enter
3. Select pre-built VSIX file from this folder or build it yourself
4. Open a `.v` file and start coding!

## Setup

The first time you open the VS Code with this extension, it will try to find the
v-analyzer binary in the PATH, if it does not find it, it will prompt you to install it.
You can install this way or manually clone the
[`v-analyzer`](https://github.com/v-analyzer/v-analyzer)
repository and specify the path to the compiled binary.

```json
{
	"v-analyzer.serverPath": "path/to/v-analyzer"
}
```

v-analyzer uses `v` to analyze code.
It calls it every time a file is saved, so you can set up auto-save to get real-time
feedback.

```json
{
	"files.autoSave": "afterDelay",
	"files.autoSaveDelay": 300
}
```

## Building from source

```bash
npm install
npm run package
```

## License

This project is under the **MIT License**.
See the
[LICENSE](https://github.com/v-analyzer/v-analyzer/blob/main/editors/code/LICENSE)
file for the full license text.
