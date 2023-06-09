rebuild-helix-grammars:
	tree-sitter generate
	rm -Rf ~/.config/helix/runtime/grammars/v.so ~/.config/helix/runtime/grammars/v.so.dSYM
	hx --grammar build
