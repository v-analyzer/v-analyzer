generate_grammar:
	cd tree_sitter_v && tree-sitter generate

run_checks: generate_grammar
	v cmd/parser-checker -o ./bin/parser-checker
	./bin/parser-checker

run_checks_silent: generate_grammar
	v cmd/parser-checker -o ./bin/parser-checker > /dev/null 2>&1
	./bin/parser-checker
