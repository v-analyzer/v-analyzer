<img width="200px" src="./docs/cover-light.png#gh-light-mode-only">
<img width="200px" src="./docs/cover-dark.png#gh-dark-mode-only">

# v-analyzer

[![Association Official Project][AssociationOfficialBadge]][AssociationUrl]
[![VSCode Extension](https://img.shields.io/badge/VS_Code-extension-25829e?logo=visualstudiocode&logoWidth=10)](https://marketplace.visualstudio.com/items?itemName=VOSCA.vscode-v-analyzer)
[![Build CI](https://github.com/v-analyzer/v-analyzer/actions/workflows/build_ci.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/build_ci.yml)
[![Analyzer tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml)
[![VS Code extension tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml)

Bring IDE features for the V programming language to VS Code, Vim, and other editors.

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

Editor plugins:

- [VS Code extension](https://github.com/v-analyzer/v-analyzer/wiki/editor-plugins#vscode)
- [Neovim plugin](https://github.com/v-analyzer/v-analyzer/wiki/editor-plugins#neovim)

Standalone binaries:

- [Webscript installation](https://github.com/v-analyzer/v-analyzer/wiki/binaries#webscript)
- [Prebuilt releases](https://github.com/v-analyzer/v-analyzer/wiki/binaries#prebuilt)
- [Build from source](https://github.com/v-analyzer/v-analyzer/wiki/binaries#build-from-source)

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
[LICENSE](https://github.com/vlang-association/v-analyzer/blob/main/LICENSE)
file for the full license text.

[AssociationOfficialBadge]: https://vosca.dev/badge.svg
[AssociationUrl]: https://vosca.dev
