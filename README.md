<img width="200px" src="./docs/cover-light.png#gh-light-mode-only">
<img width="200px" src="./docs/cover-dark.png#gh-dark-mode-only">

# v-analyzer

[![Association Official Project][AssociationOfficialBadge]][AssociationUrl]
[![VSCode Extension](https://img.shields.io/badge/VS_Code-extension-25829e?logo=visualstudiocode&logoWidth=10)](https://marketplace.visualstudio.com/items?itemName=VOSCA.vscode-v-analyzer)
[![Analyzer tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml)
[![Test tree-sitter-v](https://github.com/v-analyzer/v-analyzer/actions/workflows/test_tree_sitter_v.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/test_tree_sitter_v.yml)
[![VS Code extension tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml)

Bring IDE features for V programming languages in VS Code, Vim, and other editors.

v-analyzer provides the following features:

- code completion/IntelliSense
- go to definition, type definition
- find all references, document symbol, symbol renaming
- types and documentation on hover
- inlay hints for types and some construction like `or` block
- semantic syntax highlighting
- formatting
- signature help

## Installation

### Linux and macOS

```
v -e "$(curl -fsSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh)"
```

### Windows

```
curl 'https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh' | %{ v -e $_ }
```

## Building from source

Install dependencies:

```bash
v install
```

You can build debug or release version of the binary.
Debug version will be slower, but faster to compile.

Debug build:

```bash
v build.vsh debug
```

Release build:

```bash
v build.vsh release
```

Binary will be placed in `bin/` folder.

## Setup

Add `bin/` folder to your `$PATH` environment variable to use `v-analyzer`
command inside VS Code and other editors (**preferred**).

Or, you can specify the path to the binary in your VS Code settings:

```json
{
  "v-analyzer.serverPath": "/path/to/v-analyzer/bin/v-analyzer"
}
```

> **Note**
> Restart VS Code after changing the settings or PATH.

## Updating

To update `v-analyzer` to the latest version, run:

```bash
v-analyzer up
```

You can also update to a nightly version:

```bash
v-analyzer up --nightly
```

> **Note**
> In the nightly version you will get the latest changes, but they may not be stable!

## Authors

- `jsonrpc`, `lsp`, `tree_sitter_v` modules written initially by
  [VLS authors](https://github.com/vlang/vls) and after that in 2023 it was modified by the
  [VOSCA](https://github.com/vlang-association).

## Thanks

- [VLS](https://github.com/vlang/vls) authors for the initial Language Server implementation!
- [vscode-vlang](https://github.com/vlang/vscode-vlang) authors for the first VS Code extension!
- [rust-analyzer](https://github.com/rust-lang/rust-analyzer)
  and
  [gopls](https://github.com/golang/tools/tree/master/gopls)
  for the inspiration!
- [Tree-sitter](https://github.com/tree-sitter/tree-sitter) authors for the cool parsing library!

## License

This project is under the **MIT License**.
See the
[LICENSE](https://github.com/vlang-association/v-analyzer/blob/master/LICENSE)
file for the full license text.

[AssociationOfficialBadge]: https://vosca.dev/badge.svg
[AssociationUrl]: https://vosca.dev
