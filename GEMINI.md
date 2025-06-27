# GEMINI.md for gmd-cli

This document outlines the development plan and specifications for the `gmd-cli` project.

## 1. Project Overview

`gmd-cli` is a command-line interface (CLI) tool written in Go. Its primary purpose is to help developers manage and version-control `GEMINI.md` files independently from their main project repositories.

This solves the common problem where company policies restrict committing tool-specific configuration files (like `GEMINI.md`) into the primary codebase. `gmd-cli` allows these files to be tracked in a separate, private Git repository, providing versioning benefits without polluting the project's history.

## 2. Core Architecture

The system operates on a **dual-repository model**:

1.  **Tool Repository (`gmd-cli`)**: This public repository contains the Go source code for the `gmd` tool itself. It is a standard software project.
2.  **Data Vault Repository (`gemini-md-vault`)**: This is a separate, user-owned **private** Git repository. It acts as a centralized "vault" to store the `GEMINI.md` files from all of the user's projects.

The `gmd` executable is the orchestrator that synchronizes files between a user's local project directories and their private data vault.

## 3. Technical Stack

- **Language**: Go (Golang)
- **Reasoning**: Chosen for its ability to produce single, dependency-free, cross-platform binary executables, which provides the best user experience for a CLI tool. Its strong standard library for file system and command execution is perfectly suited for this task.

## 4. Configuration

The tool will be configured via a TOML file located at `~/.config/gmd/config.toml`.

**Initial Configuration:**

```toml
# The SSH or HTTPS Git URL for the user's private data vault repository.
vault_url = "git@github.com:user/gemini-md-vault.git"
```

The `gmd init` command will be responsible for creating this file and prompting the user for the `vault_url`.

## 5. Command-Line Interface (CLI) Specification

The tool will be invoked as `gmd`.

### 5.1. `gmd init`

- **Action**: Initializes the `gmd` configuration.
- **Workflow**:
  1.  Checks if `~/.config/gmd/config.toml` exists.
  2.  If not, it creates the directory and an empty config file.
  3.  Prompts the user interactively to enter their private `gemini-md-vault` repository URL.
  4.  Saves the URL to the configuration file.
- **Options**:
  - `--vault-url <url>`: Allows providing the vault URL directly as a flag, skipping the interactive prompt.

### 5.2. `gmd sync`

- **Action**: Scans the current project, finds all `GEMINI.md` files, and commits them to the data vault.
- **Workflow**:
  1.  Identifies the project's root directory (where the `.git` folder is).
  2.  Scans the entire project directory for files named `GEMINI.md`.
  3.  Clones the `gemini-md-vault` repo into a temporary, hidden directory (e.g., `/tmp/gmd-vault-clone`).
  4.  Copies the found `GEMINI.md` files to the temporary clone, preserving their relative paths within a subdirectory named after the project (e.g., `gmd-cli/rules/gemini/GEMINI.md`).
  5.  Within the temporary clone, executes `git add .`, `git commit`, and `git push`.
  6.  The commit message will be automated, e.g., `[gmd] Sync files for project 'my-project'`.
- **Note**: The project name will be derived from the root directory's name.

### 5.3. `gmd restore`

- **Action**: Pulls the latest `GEMINI.md` files from the data vault and places them into the current project directory.
- **Workflow**:
  1.  Clones the `gemini-md-vault` repo to a temporary directory.
  2.  Finds the subdirectory corresponding to the current project.
  3.  Copies all `GEMINI.md` files from that subdirectory back into the local project, recreating the correct directory structure.
  4.  It will overwrite existing `GEMINI.md` files if they exist.

### 5.4. `gmd status`

- **Action**: Compares the local `GEMINI.md` files with their versions in the data vault.
- **Workflow**:
  1.  Performs a temporary clone of the vault.
  2.  For each local `GEMINI.md` file, it calculates its hash.
  3.  It compares the hash with the corresponding file's hash in the vault.
  4.  Displays the status: `new`, `modified`, `untracked`, or `synced`.

### 5.5. `gmd list`

- **Action**: Lists all `GEMINI.md` files currently tracked in the data vault for the current project.

### 5.6. `gmd log`

- **Action**: Shows the Git commit history for the current project's subdirectory within the data vault.
- **Workflow**: Executes `git log` within the project's subdirectory inside a temporary clone of the vault.

## 6. Development Plan

1.  **Phase 1: Foundation**

    - Set up the Go project structure (`go mod init gmd-cli`).
    - Implement the configuration logic (`init` command and reading from `~/.config/gmd/config.toml`).
    - Use a CLI framework library like `cobra` or `urfave/cli` to structure the commands.

2.  **Phase 2: Core Logic**

    - Implement the `sync` command. This is the most critical feature. It involves file scanning (`filepath.Walk`) and Git command execution (`os/exec`).
    - Implement the `restore` command.

3.  **Phase 3: Read-only Commands**

    - Implement `status`, `list`, and `log`.

4.  **Phase 4: Refinement**
    - Add robust error handling and user-friendly output.
    - Write unit and integration tests.
    - Set up a build pipeline (e.g., using GitHub Actions) to automate cross-platform builds and releases.
