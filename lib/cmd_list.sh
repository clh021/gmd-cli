#!/bin/bash

# --- Commands ---

cmd_list() {
	local project_root
	project_root="$(find_project_root)"
	echo "Project root found at: ${project_root}"

	local vault_url
	vault_url="$(parse_toml_value "vault_url" "${CONFIG_FILE}")"
	if [[ -z "$vault_url" ]]; then
		error_exit "Vault URL not configured. Please run 'gmd init' first."
	fi

	echo "Vault URL: ${vault_url}"

	# Manage the persistent vault clone (same as sync/restore/status)
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
--- GEMINI.md files in vault for project '${project_name}' ---"

	if [[ ! -d "$project_vault_path" ]]; then
		echo "No GEMINI.md files found for project '${project_name}' in the vault."
		return 0
	fi

	local gemini_files_in_vault=()
	while IFS= read -r -d '' file; do
		gemini_files_in_vault+=("${file#$project_vault_path/}") # Store relative path within project_vault_path
	done < <(find "$project_vault_path" -type f -name "GEMINI.md" -print0)

	if [[ ${#gemini_files_in_vault[@]} -eq 0 ]]; then
		echo "No GEMINI.md files found for project '${project_name}' in the vault."
	else
		for file in "${gemini_files_in_vault[@]}"; do
			echo " - ${file}"
		done
	fi

	echo "---"
}
