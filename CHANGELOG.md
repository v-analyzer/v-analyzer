# v-analyser Changelog

## [0.0.3-beta.1] - 2023/12/13
Third public release.

Syntax enhancements & bug fixes:
∙ Fix support for multiline comments (#75)
∙ Fix interface ref type highlight (#76)
∙ Fix support for struct field attributes (#74)
∙ Fix interface embeds and interface fields (#78)
∙ Fix `assert cond, message` statements (#65)
∙ Support @[attribute], fix signature, fix interface highlights

Language server enhancements:
∙ Enable exit commands, to prevent lingering v-analyzer processes after
an editor restart (#77)
∙ server: fix NO_RESULT_CALLBACK_FOUND in neovim (#59)
∙ Build the v-analyzer executable on linux as static in release mode, to
make it more robust and usable in more distros.

Others:
∙ docs: add neovim install instructions (#63)
∙ CI improvements, to make releases easier, and to keep the code quality high.
∙ Update the vscode extension package to vscode-v-analyzer-0.0.3.vsix
∙ Make `v-analyzer --version` show the build commit as well.

Note: this is still a beta version, expect bugs and please report them in
our [issues tracker](https://github.com/v-analyzer/v-analyzer/issues) .

## [0.0.2-beta.1] - 2023/11/21
Second public release. 

Small internal improvements to the documentation, ci, build scripts.

Fix compilation with latest V.

Update https://github.com/v-analyzer/v-tree-sitter from the latest
upstream version from https://github.com/tree-sitter/tree-sitter .

This is still a beta version, expect bugs and please report them in
our [issues tracker](https://github.com/v-analyzer/v-analyzer/issues) .


## [0.0.1-beta.1] - 2023/07/03

First public release.

Please note that this is a beta version, so it may contain any bugs.
