# tree-sitter-v

V language grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter)

This grammar is heavily derived from the following language grammars:

- [tree-sitter-go](https://github.com/tree-sitter/tree-sitter-go)
- [tree-sitter-ruby](https://github.com/tree-sitter/tree-sitter-ruby/)
- [tree-sitter-c](https://github.com/tree-sitter/tree-sitter-c/)

## Limitations

1. It does not support all deprecated/outdated syntaxes to avoid any ambiguities and to enforce the
   one-way philosophy as much as possible.
2. Assembly/SQL code in ASM/SQL block nodes are loosely checked and parsed immediately regardless of
   the content.

## Authors

This project initially started by
[nedpals](https://github.com/nedpals)
and after that in 2023 it was heavily modified by the
[VOSCA](https://github.com/vlang-association).

## License

This project is under the **MIT License**.
See the
[LICENSE](https://github.com/vlang-association/v-analyzer/tree_sitter_v/blob/master/LICENSE)
file for the full license text.
