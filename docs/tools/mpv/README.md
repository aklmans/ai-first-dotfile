# mpv 配置

配置文件位于 `home/.config/mpv/`。

这是 mpv 的配置目录，包含 `mpv.conf`、`input.conf`、`scripts/`、`script-opts/`、`shaders/`。

`home/.config/mpv/scripts/modernx.lua` 的控制按钮样式默认使用
`material-design-iconic-font` 风格的字形。该字体未随仓库迁移，属于运行时可选依赖，
目的是避免提交第三方字体二进制与版权不明文件。

## 部署方式

本仓库以 `home/` 作为 tracked home 目录。部署时，`home/.config/mpv/` 会被同步到 `~/.config/mpv/`，目录里的相对引用会按这个最终位置解析。

## 使用说明

- 下列脚本下载命令要在 tracked 的 `home/.config/mpv/` 根目录执行，或显式写成完整目标路径。
- `scripts/`、`script-opts/`、`shaders/` 里的内容都会随仓库同步到 `~/.config/mpv/` 下。
- 字体可选项（任选其一）：
  - `./bootstrap/install/mpv.sh` 在环境可用时会尝试安装公开字体包（例如 `font-material-design-icons-webfont`）。
  - 手动安装：下载公开字体并放到 `~/Library/Fonts/`，然后重启 mpv。
- 如果脚本来源于上游仓库，更新时只改对应文件，不要把路径写成临时下载位置。

```bash
cd home/.config/mpv
curl -L https://github.com/cyl0/ModernX/raw/main/modernx.lua > scripts/modernx.lua
curl -L https://github.com/po5/thumbfast/raw/master/thumbfast.lua > scripts/thumbfast.lua
curl -L https://github.com/jonniek/mpv-playlistmanager/raw/master/playlistmanager.lua > scripts/playlistmanager.lua
curl -L https://github.com/mpv-player/mpv/raw/master/TOOLS/lua/ontop-playback.lua > scripts/ontop-playback.lua
curl -L https://github.com/occivink/mpv-scripts/raw/master/scripts/seek-to.lua > scripts/seek-to.lua
```
