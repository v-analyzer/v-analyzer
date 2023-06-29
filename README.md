<img width="200px" src="./docs/cover.png">

# v-analyzer

[![Association Official Project][AssociationOfficialBadge]][AssociationUrl]
[![Analyzer tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/analyzer_tests.yml)
[![Test tree-sitter-v](https://github.com/v-analyzer/v-analyzer/actions/workflows/test_tree_sitter_v.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/test_tree_sitter_v.yml)
[![VS Code extension tests](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml/badge.svg)](https://github.com/v-analyzer/v-analyzer/actions/workflows/vscode_extension_tests.yml)

Bring IDE features for V programming languages in VS Code, Vim, and other editors

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

## Authors

- `jsonrpc`, `lsp`, `tree_sitter_v` modules written initially by
  [VLS authors](https://github.com/vlang/vls) and after that in 2023 it was modified by the
  [VOSCA](https://github.com/vlang-association).

## License

This project is under the **MIT License**.
See the
[LICENSE](https://github.com/vlang-association/v-analyzer/blob/master/LICENSE)
file for the full license text.

[AssociationOfficialBadge]: https://vosca.dev/badge.svg
[AssociationUrl]: https://vosca.dev
