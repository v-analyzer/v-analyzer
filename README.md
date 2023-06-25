# v-analyzer

Bring IDE features for V programming languages in VS Code, Vim, and other editors

## Building from source

Debug build:

```bash
v install
make build-debug
```

Release build:

```bash
v install
make build-prod
```

Binary will be placed in `bin/` folder.

## Setup

Add `bin/` folder to your `$PATH` environment variable to use `v-analyzer`
command inside VS Code and other editors.

Or, you can specify the path to the binary in your VS Code settings:

```json
{
  "v-analyzer.serverPath": "/path/to/v-analyzer/bin"
}
```

Restart VS Code after changing the settings or PATH.

## Authors

- `jsonrpc`, `lsp`, `tree_sitter_v` modules written initially by
  [nedpals](https://github.com/nedpals) and after that in 2023 it was modified by the
  [VOSCA](https://github.com/vlang-association).

## License

This project is under the **MIT License**.
See the
[LICENSE](https://github.com/vlang-association/v-analyzer/blob/master/LICENSE)
file for the full license text.
