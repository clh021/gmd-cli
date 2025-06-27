[简体中文](README_zh.md) | English

# gmd-cli

`gmd-cli` is a command-line interface (CLI) tool written entirely in **Bash script**. Its primary purpose is to help developers manage and version-control `GEMINI.md` files independently from their main project repositories.

This solves the common problem where, due to certain special reasons, committing tool-specific configuration files (like `GEMINI.md`) into the primary codebase is restricted. `gmd-cli` allows these files to be tracked in a separate, private Git repository, providing versioning benefits without polluting the project's history.

## Features

- **`init`**: Initializes the `gmd` configuration, prompting for your private `gemini-md-vault` repository URL.
- **`sync`**: Scans the current project for `GEMINI.md` files and commits them to your data vault, preserving their relative paths.
- **`restore`**: Pulls the latest `GEMINI.md` files from your data vault and places them into the current project directory.
- **`status`**: Compares local `GEMINI.md` files with their versions in the data vault, showing `new`, `modified`, `untracked`, or `synced` status.
- **`list`**: Lists all `GEMINI.md` files currently tracked in the data vault for the current project.
- **`log`**: Shows the Git commit history for the current project's subdirectory within the data vault.

## Installation

You can download the latest `gmd` executable from the [GitHub Releases](https://github.com/clh021/gmd-cli/releases) page.

Once downloaded, make it executable and place it in your PATH:

```bash
# Download the latest release (replace v1.0.0 with the actual version)
curl -L https://github.com/clh021/gmd-cli/releases/download/v1.0.0/gmd -o gmd

# Make it executable
chmod +x gmd

# Move it to a directory in your PATH (e.g., /usr/local/bin or ~/.local/bin)
sudo mv gmd /usr/local/bin/
```

## Configuration

The tool will be configured via a TOML file located at `~/.config/gmd/config.toml`.

Run `gmd init` to set up your `gemini-md-vault` repository URL:

```bash
gmd init
# Follow the prompts to enter your vault URL
```

Alternatively, you can provide the URL directly:

```bash
gmd init --vault-url "git@github.com:user/gemini-md-vault.git"
```

## Usage

```bash
gmd <command> [options]
```

See the [Features](#features) section for a list of available commands.

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](#license) file for details.
