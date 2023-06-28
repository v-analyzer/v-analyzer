build-vscode-extension:
	cd editors/code && npm install
	cd editors/code && npm run package

generate_grammar:
	cd tree_sitter_v && tree-sitter generate
