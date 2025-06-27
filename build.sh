#!/bin/bash

set -euo pipefail

OUTPUT_DIR="dist"
OUTPUT_FILE="${OUTPUT_DIR}/gmd"
TEMP_FILE="${OUTPUT_DIR}/gmd.tmp"

mkdir -p "${OUTPUT_DIR}"

# Start with the shebang
echo "#!/bin/bash" >"${TEMP_FILE}"

# Append helper functions
cat lib/helpers.sh >>"${TEMP_FILE}"

# Append command scripts
for cmd_file in lib/cmd_*.sh; do
	cat "${cmd_file}" >>"${TEMP_FILE}"
done

# Append the main function definition and call
cat <<'EOF' >>"${TEMP_FILE}"

# --- Configuration Variables ---
CONFIG_DIR="${HOME}/.config/gmd"
CONFIG_FILE="${CONFIG_DIR}/config.toml"
# Define cache dir for commands that might need it
CACHE_DIR="${HOME}/.cache/gmd"

# --- Main Logic ---
main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: gmd <command> [options]"
    echo "Commands: init, sync, restore, status, list, log"
    exit 1
  fi

  local command="$1"
  shift # Remove command from arguments

  # Execute the command function
  case "$command" in
    init|sync|restore|status|list|log)
      "cmd_${command}" "$@"
      ;;
    *)
      error_exit "Unknown command: $command"
      ;;
  esac
}

main "$@"
EOF

# Remove redundant shebangs from appended files
sed -i -E 's/^#!\/bin\/bash//g' "${TEMP_FILE}"

# Remove SCRIPT_DIR and LIB_DIR definitions (they are not needed in the single file)
sed -i -E '/^SCRIPT_DIR=.*$/d' "${TEMP_FILE}"
sed -i -E '/^LIB_DIR=.*$/d' "${TEMP_FILE}"

# Remove source commands (they are not needed in the single file)
sed -i -E '/^source "\$\{LIB_DIR\}\/helpers.sh"$/d' "${TEMP_FILE}"
sed -i -E '/^# shellcheck source=.*$/d' "${TEMP_FILE}"

# Move the temporary file to the final output file
mv "${TEMP_FILE}" "${OUTPUT_FILE}"

chmod +x "${OUTPUT_FILE}"

echo "Single executable created at ${OUTPUT_FILE}"
