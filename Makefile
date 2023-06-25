build-debug:
	if [ ! -d "./bin" ]; then mkdir bin; fi
	v ./cmd/v-analyzer -o ./bin/v-analyzer -g -d use_libbacktrace

build-prod:
	if [ ! -d "./bin" ]; then mkdir bin; fi
	v ./cmd/v-analyzer -o ./bin/v-analyzer -cflags "-O3 -DNDEBUG" -prod

build-vscode-extension:
	cd editors/code && npm install
	cd editors/code && npm run package

generate_grammar:
	cd tree_sitter_v && tree-sitter generate
