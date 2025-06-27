#!/bin/bash

# --- Commands ---

cmd_init() {
	local vault_url=""
	local new_vault_url_provided=false # Flag to track if --vault-url was given

	# Parse options
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--vault-url)
			vault_url="$2"
			new_vault_url_provided=true
			shift # past argument
			shift # past value
			;;
		*)
			error_exit "Unknown option: $1"
			;;
		esac
	done

	mkdir -p "${CONFIG_DIR}" || error_exit "Failed to create config directory: ${CONFIG_DIR}"

	if [[ -f "${CONFIG_FILE}" ]]; then
		echo "Configuration file already exists at ${CONFIG_FILE}."
		if [[ "$new_vault_url_provided" == "true" ]]; then
			# If a new URL was provided, overwrite the file
			echo "Updating vault URL to: ${vault_url}"
			echo "vault_url = \"${vault_url}\"" >"${CONFIG_FILE}" || error_exit "Failed to write config file."
			echo "Configuration updated at ${CONFIG_FILE}"
		else
			# If no new URL was provided, just confirm existing config
			local existing_vault_url
			existing_vault_url="$(parse_toml_value "vault_url" "${CONFIG_FILE}")"
			echo "Current vault URL: ${existing_vault_url}"
			echo "No changes made. To update, use 'gmd init --vault-url <new_url>' or delete the config file."
		fi
	else
		# Config file does not exist, proceed with creation
		if [[ -z "$vault_url" ]]; then
			echo -n "Please enter the SSH or HTTPS Git URL for your private gemini-md-vault repository: "
			read -r vault_url
			if [[ -z "$vault_url" ]]; then
				error_exit "Vault URL cannot be empty."
			fi
		fi
		echo "vault_url = \"${vault_url}\"" >"${CONFIG_FILE}" || error_exit "Failed to write config file."
		echo "Successfully created configuration at ${CONFIG_FILE}"
	fi
}
