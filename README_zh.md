[English](README.md) | 简体中文

# gmd-cli

`gmd-cli` 是一个完全用 **Bash 脚本**编写的命令行界面 (CLI) 工具。其主要目的是帮助开发人员独立于其主项目仓库管理和版本控制 `GEMINI.md` 文件。

这解决了由于某些特殊原因，将工具特定配置文件（如 `GEMINI.md`）提交到主代码库受到限制的常见问题。`gmd-cli` 允许这些文件在单独的私有 Git 仓库中进行跟踪，从而在不污染项目历史记录的情况下提供版本控制的好处。

## 功能

- **`init`**: 初始化 `gmd` 配置，提示您输入私有 `gemini-md-vault` 仓库的 URL。
- **`sync`**: 扫描当前项目中的 `GEMINI.md` 文件，并将其提交到您的数据仓库，同时保留其相对路径。
- **`restore`**: 从您的数据仓库中拉取最新的 `GEMINI.md` 文件，并将其放置到当前项目目录中。
- **`status`**: 比较本地 `GEMINI.md` 文件与数据仓库中的版本，显示 `new`（新增）、`modified`（已修改）、`untracked`（未跟踪）或 `synced`（已同步）状态。
- **`list`**: 列出当前项目在数据仓库中跟踪的所有 `GEMINI.md` 文件。
- **`log`**: 显示数据仓库中当前项目子目录的 Git 提交历史。

## 安装

您可以从 [GitHub Releases](https://github.com/clh021/gmd-cli/releases) 页面下载最新的 `gmd` 可执行文件。

下载后，使其可执行并将其放置在您的 PATH 中：

```bash
# 下载最新版本（将 v1.0.0 替换为实际版本）
curl -L https://github.com/clh021/gmd-cli/releases/download/v1.0.0/gmd -o gmd

# 使其可执行
chmod +x gmd

# 将其移动到您的 PATH 中的目录（例如 /usr/local/bin 或 ~/.local/bin）
sudo mv gmd /usr/local/bin/
```

## 配置

该工具将通过位于 `~/.config/gmd/config.toml` 的 TOML 文件进行配置。

运行 `gmd init` 以设置您的 `gemini-md-vault` 仓库 URL：

```bash
gmd init
# 按照提示输入您的仓库 URL
```

或者，您可以直接提供 URL：

```bash
gmd init --vault-url "git@github.com:user/gemini-md-vault.git"
```

## 使用方法

```bash
gmd <command> [options]
```

有关可用命令的列表，请参阅[功能](#功能)部分。

## 贡献

欢迎贡献！请随时提出问题或提交拉取请求。

## 许可证

本项目采用 MIT 许可证 - 有关详细信息，请参阅 [LICENSE](#license) 文件。
