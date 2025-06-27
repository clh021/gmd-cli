#!/bin/bash

# --- Commands ---

cmd_status() {
	local project_root
	project_root="$(find_project_root)"
	echo "Project root found at: ${project_root}"

	local vault_url
	vault_url="$(parse_toml_value "vault_url" "${CONFIG_FILE}")"
	if [[ -z "$vault_url" ]]; then
		error_exit "Vault URL not configured. Please run 'gmd init' first."
	fi

	echo "Vault URL: ${vault_url}"

	# Manage the persistent vault clone (same as sync/restore)
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
--- Status for project '${project_name}' ---"

	local local_gemini_files=()
	while IFS= read -r -d '' file; do
		local_gemini_files+=("${file#$project_root/}") # Store relative path
	done < <(find "$project_root" -type f -name "GEMINI.md" -print0)

	if [[ ${#local_gemini_files[@]} -eq 0 ]]; then
		echo "No local GEMINI.md files found in this project."
	fi

	for local_file_rel_path in "${local_gemini_files[@]}"; do
		local local_file_abs_path="${project_root}/${local_file_rel_path}"
		local vault_file_abs_path="${project_vault_path}/${local_file_rel_path}"

		local local_hash
		local_hash="$(sha256sum "$local_file_abs_path" | awk '{print $1}')"

		if [[ -f "$vault_file_abs_path" ]]; then
			local vault_hash
			vault_hash="$(sha256sum "$vault_file_abs_path" | awk '{print $1}')"

			if [[ "$local_hash" == "$vault_hash" ]]; then
				echo "Synced: ${local_file_rel_path}"
			else
				echo "Modified: ${local_file_rel_path}"
			fi
		else
			echo "New: ${local_file_rel_path}"
		fi
	done

	# Check for files in vault but not locally (untracked from vault's perspective)
	if [[ -d "$project_vault_path" ]]; then
		local vault_only_files=()
		while IFS= read -r -d '' file; do
			local vault_file_rel_path="${file#$project_vault_path/}"
			local local_file_check_path="${project_root}/${vault_file_rel_path}"
			if [[ ! -f "$local_file_check_path" ]]; then
				vault_only_files+=("${vault_file_rel_path}")
			fi
		done < <(find "$project_vault_path" -type f -name "GEMINI.md" -print0)

		for vault_only_file in "${vault_only_files[@]}"; do
			echo "Untracked (local missing): ${vault_only_file}"
		done
	fi

	echo "---"
}
