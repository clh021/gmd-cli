#!/bin/bash

# --- Commands ---

cmd_sync() {
	local project_root
	project_root="$(find_project_root)"
	echo "Project root found at: ${project_root}"

	local vault_url
	vault_url="$(parse_toml_value "vault_url" "${CONFIG_FILE}")"
	if [[ -z "$vault_url" ]]; then
		error_exit "Vault URL not configured. Please run 'gmd init' first."
	fi

	echo "Vault URL: ${vault_url}"

	# Find all GEMINI.md files
	local gemini_files=()
	while IFS= read -r -d '' file; do
		gemini_files+=("${file#$project_root/}") # Store relative path
	done < <(find "$project_root" -type f -name "GEMINI.md" -print0)

	if [[ ${#gemini_files[@]} -eq 0 ]]; then
		echo "No GEMINI.md files found in this project. Nothing to sync."
		return 0
	fi

	# Manage the persistent vault clone
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

	# Copy files to the cloned repo
	local project_name
	project_name="$(basename "$project_root")"
	for file in "${gemini_files[@]}"; do
		local dest_path="${vault_clone_dir}/${project_name}/${file}"
		mkdir -p "$(dirname "$dest_path")" || error_exit "Failed to create directory: $(dirname "$dest_path")"
		cp "${project_root}/${file}" "$dest_path" || error_exit "Failed to copy file: ${project_root}/${file}"
	done

	# Add, commit, and push
	(
		cd "${vault_clone_dir}" || error_exit "Failed to change directory to vault clone."
		export SSH_ASKPASS=""
		export GIT_SSH_COMMAND="ssh -A -o BatchMode=yes"

		git add . || error_exit "Failed to add files to index."

		# Check if there are changes to commit
		if [[ -z "$(git status --porcelain)" ]]; then
			echo "No changes to sync. Vault is up-to-date."
			return 0
		fi

		local commit_msg="[gmd] Sync files for project '${project_name}'"
		git commit -m "${commit_msg}" || error_exit "Failed to commit changes."

		echo "Pushing changes to the vault..."
		git push || error_exit "Failed to push to remote."
	)

	echo "Successfully synced files to the vault."
}
