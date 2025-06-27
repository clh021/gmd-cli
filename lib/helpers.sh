#!/bin/bash

# Helper Functions

# Function to display error messages and exit
error_exit() {
	echo "Error: $1" >&2
	exit 1
}

# Function to find the project root (directory containing .git)
find_project_root() {
	local current_dir
	current_dir="$(pwd)"

	while [[ "$current_dir" != "/" ]]; do
		if [[ -d "$current_dir/.git" ]]; then
			echo "$current_dir"
			return 0
		fi
		current_dir="$(dirname "$current_dir")"
	done

	error_exit "Not a git repository (or any of the parent directories)."
}

# Function to parse TOML (basic, for vault_url only)
# This is a very basic parser and only works for simple key=value pairs
# It will be improved as needed.
parse_toml_value() {
	local key="$1"
	local file="$2"
	grep "^${key}\s*=" "$file" | head -n 1 | sed -E "s/^${key}\s*=\s*['\"]?([^'\"]*)['\"]?$/\1/"
}
