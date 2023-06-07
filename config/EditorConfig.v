module config

import toml

pub enum SemanticTokensMode {
	full
	syntax
	none_
}

pub struct InlayHintsConfig {
pub mut:
	enable                    bool = true
	enable_range_hints        bool = true
	enable_type_hints         bool = true
	enable_implicit_err_hints bool = true
}

pub struct EditorConfig {
pub:
	root string
	path string
pub mut:
	custom_vroot           string
	custom_cache_dir       string
	inlay_hints            InlayHintsConfig
	enable_semantic_tokens SemanticTokensMode = SemanticTokensMode.full
}

pub fn from_toml(root string, path string, content string) !EditorConfig {
	mut config := EditorConfig{
		root: root
		path: path
	}

	res := toml.parse_text(content)!

	custom_vroot_value := res.value('custom_vroot')
	if custom_vroot_value is string {
		config.custom_vroot = custom_vroot_value
	}

	custom_cache_dir := res.value('custom_cache_dir')
	if custom_cache_dir is string {
		config.custom_cache_dir = custom_cache_dir
	}

	enable_semantic_tokens := res.value('enable_semantic_tokens')
	if enable_semantic_tokens is string {
		config.enable_semantic_tokens = match enable_semantic_tokens {
			'full' { SemanticTokensMode.full }
			'syntax' { SemanticTokensMode.syntax }
			'none' { SemanticTokensMode.none_ }
			else { SemanticTokensMode.full }
		}
	}

	inlay_hints_table := res.value('inlay_hints')
	enable_value := inlay_hints_table.value('enable')
	config.inlay_hints.enable = if enable_value is toml.Null {
		true // default to true
	} else {
		enable_value.bool()
	}

	enable_range_hints_value := inlay_hints_table.value('enable_range_hints')
	config.inlay_hints.enable_range_hints = if enable_range_hints_value is toml.Null {
		true // default to true
	} else {
		enable_range_hints_value.bool()
	}

	enable_type_hints_value := inlay_hints_table.value('enable_type_hints')
	config.inlay_hints.enable_type_hints = if enable_type_hints_value is toml.Null {
		true // default to true
	} else {
		enable_type_hints_value.bool()
	}

	enable_implicit_err_hints := inlay_hints_table.value('enable_implicit_err_hints')
	config.inlay_hints.enable_implicit_err_hints = if enable_implicit_err_hints is toml.Null {
		true // default to true
	} else {
		enable_implicit_err_hints.bool()
	}

	return config
}

pub fn (e &EditorConfig) path() string {
	if e.path.starts_with(e.root) {
		return e.path[e.root.len + 1..]
	}

	return e.path
}

pub fn (e &EditorConfig) is_local() bool {
	return e.path.starts_with(e.root)
}
