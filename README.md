<img width="200px" src="./docs/cover.png">

# v-analyzer

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
make build-debug
```

Release build:

```bash
make build-prod
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
