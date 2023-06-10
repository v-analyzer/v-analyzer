build-debug:
	mkdir bin
	v ./cmd/spavn-analyzer -o ./bin/spavn-analyzer -g -d use_libbacktrace

build-prod:
	mkdir bin
	v ./cmd/spavn-analyzer -o ./bin/spavn-analyzer -cflags "-O3 -DNDEBUG" -prod

build-vscode-extension:
	cd editors/code && npm install
	cd editors/code && npm run package

generate_grammar:
	cd tree_sitter_v && tree-sitter generate
