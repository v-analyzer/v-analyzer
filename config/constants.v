module config

import os
import utils

pub const (
	// analyzer_name is the name of the analyzer.
	analyzer_name               = 'spavn-analyzer'

	// analyzer_config_name is the name of the analyzer's configuration
	analyzer_config_name        = 'config.toml'

	// analyzer_configs_path is the path to the directory containing the
	// root configuration files for the analyzer.
	analyzer_configs_path       = utils.expand_tilde_to_home('~/.config/spavn-analyzer')

	// analyzer_log_file_name is the name of the log file for the analyzer.
	analyzer_log_file_name      = 'spavn-analyzer.log'

	// analyzer_logs_path is the path to the directory containing the
	// logs for the analyzer.
	analyzer_logs_path          = os.join_path(analyzer_configs_path, 'logs')

	// analyzer_global_config_path is the path to the global configuration
	// file for the analyzer.
	analyzer_global_config_path = os.join_path(analyzer_configs_path, analyzer_config_name)

	// analyzer_caches_path is the path to the directory containing the
	// cache files for the analyzer.
	analyzer_caches_path        = os.join_path(os.cache_dir(), 'spavn-analyzer')

	// analyzer_stubs_path is the path to the directory containing the
	// unpacked stub files for the analyzer.
	analyzer_stubs_path         = os.join_path(analyzer_configs_path, 'metadata')
)

pub const default = '# Specifies the path to the V installation directory with `v` executable.
# If not set, the plugin will try to find it on its own.
# Basically, you don\'t need to set it.
#custom_vroot = "~/v"

# Specifies the path where to store the cache.
# By default, it is stored in the system\'s cache directory.
# You can set it to `./` to store the cache in the project\'s directory, this is useful
# if you want to debug the analyzer.
# Basically, you don\'t need to set it.
#custom_cache_dir = "./"

# Specifies whenever to enable semantic tokens or not.
# - `full` — enables all semantic tokens. In this mode analyzer resolves all symbols
#    in the file to provide the most accurate highlighting.
# - `syntax` — enables only syntax tokens, such tokens highlight structural elements
#    such as field names or import names.
#    The fastest option, which is always enabled when the file contains more than 1000 lines.
# - `none` — disables semantic tokens.
# By default, `full` for files with less than 1000 lines, `syntax` for files with more.
enable_semantic_tokens = "full"

# Specifies inlay hints to show.
[inlay_hints]
# Specifies whenever to enable inlay hints or not.
# By default, they are enabled.
enable = true

# Specifies whenever to show type hints for ranges or not.
# Example:
# ```
# 0 ≤ .. < 10
#   ^    ^
# ```
# or:
# ```
# a[0 ≤ .. < 10]
#     ^    ^
# ```
enable_range_hints = true

# Specifies whenever to show type hints for variables or not.
# Example:
# ```
# name : Foo := foo()
#      ^^^^^
# ```
enable_type_hints = true

# Specifies whenever to show hints for implicit err variables or not.
# Example:
# ```
# foo() or { err ->
#            ^^^^^^
# }
# ```
enable_implicit_err_hints = true

# Specifies whenever to show hints for function parameters in call or not.
# Example:
# ```
# fn foo(a int, b int) int {}
#
# foo(a: 1, b: 2)
#     ^^    ^^
enable_parameter_name_hints = true

# Specifies whenever to show type hints for constants or not.
# Example:
# ```
# const foo : int = 1
#           ^^^^^
# ```
enable_constant_type_hints = true

# Specifies code lenses to show.
[code_lens]
# Specifies whenever to enable code lenses or not.
# By default, they are enabled.
enable = true

# Specifies whenever to show code lenses for main function to run current directory or not.
# Example:
# ```
# ▶ Run
# fn main() {}
# ```
enable_run_lens = true

# Specifies whenever to show code lenses for interface inheritors or not.
# Example:
# ```
# 2 implementations
# interface Foo {}
# ```
enable_inheritors_lens = true

# Specifies whenever to show code lenses for structs implementing interfaces or not.
# Example:
# ```
# implemented 2 interfaces
# struct Boo {}
# ```
enable_super_interfaces_lens = true
'
