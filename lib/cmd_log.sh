#!/bin/bash

# --- Commands ---

cmd_log() {
	local project_root
	project_root="$(find_project_root)"
	echo "Project root found at: ${project_root}"

	local vault_url
	vault_url="$(parse_toml_value "vault_url" "${CONFIG_FILE}")"
	if [[ -z "$vault_url" ]]; then
		error_exit "Vault URL not configured. Please run 'gmd init' first."
	fi

	echo "Vault URL: ${vault_url}"

	# Manage the persistent vault clone (same as other commands)
	local vault_clone_dir="${CACHE_DIR}/vault_clone"
	if [[ ! -d "${vault_clone_dir}/.git" ]]; then
		echo "Vault clone not found at ${vault_clone_dir}. Cloning..."
		mkdir -p "${vault_clone_dir}" || error_exit "Failed to create vault clone directory."
		(
			export SSH_ASKPASS=""
			export GIT_SSH_COMMAND="ssh -A -o BatchMode=yes"
			git clone "${vault_url}" "${vault_clone_dir}" || error_exit "Failed to clone vault."
		)
	else
		echo "Vault clone found at ${vault_clone_dir}. Pulling latest changes..."
		(
			cd "${vault_clone_dir}" || error_exit "Failed to change directory to vault clone."
			export SSH_ASKPASS=""
			export GIT_SSH_COMMAND="ssh -A -o BatchMode=yes"
			git pull || error_exit "Failed to pull latest changes from vault."
		)
	fi

	local project_name
	project_name="$(basename "$project_root")"
	local project_vault_path="${vault_clone_dir}/${project_name}"

	echo "
--- Git Log for project '${project_name}' in vault ---"

	if [[ ! -d "$project_vault_path" ]]; then
		echo "No entries found for project '${project_name}' in the vault. No log to display."
		return 0
	fi

	# Execute git log within the project's subdirectory in the vault
	(
		cd "$project_vault_path" || error_exit "Failed to change directory to ${project_vault_path}"
		export SSH_ASKPASS=""
		export GIT_SSH_COMMAND="ssh -A -o BatchMode=yes"
		git log "$@" # Pass through any additional arguments to git log
	)

	echo "---"
}
