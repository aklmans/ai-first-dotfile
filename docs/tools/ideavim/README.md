# IdeaVim 使用指南

配置文件位于 `home/.ideavimrc`。

这是 JetBrains 系列 IDE 的 Vim 模式配置，用来统一编辑器内的按键映射、命令和行为。

## 部署方式

本仓库以 `home/` 作为 tracked home 目录。部署时，`home/.ideavimrc` 会被同步到 `~/.ideavimrc`。

## 使用说明

- 这个文件只影响启用了 IdeaVim 的 IDE，不会改动系统级 Vim。
- 修改后通常需要重载 IDE 配置，或重启 IDE，才能看到新的映射和选项。
- 如果写入了依赖本机插件或路径的内容，记得保持可移植性，否则在其他机器上可能失效。
