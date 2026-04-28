# mpv 配置

配置文件位于 `home/.config/mpv/`。

这是 mpv 的完整配置目录，包含 `mpv.conf`、`input.conf`、`scripts/`、`script-opts/`、`shaders/` 和 `fonts/` 等子目录。

## 部署方式

本仓库以 `home/` 作为 tracked home 目录。部署时，`home/.config/mpv/` 会被同步到 `~/.config/mpv/`，目录里的相对引用会按这个最终位置解析。

## 使用说明

- 下面这些下载命令要在 tracked 的 `home/.config/mpv/` 根目录执行，或显式写成完整目标路径。
- `scripts/`、`script-opts/`、`shaders/` 和 `fonts/` 里的内容都是本地资源，部署后需要一起存在于 `~/.config/mpv/` 下。
- 如果脚本来源于上游仓库，更新时只改对应文件，不要把路径写成临时下载位置。

```bash
cd home/.config/mpv
curl -L https://github.com/cyl0/ModernX/raw/main/modernx.lua > scripts/modernx.lua
curl -L https://github.com/po5/thumbfast/raw/master/thumbfast.lua > scripts/thumbfast.lua
curl -L https://github.com/jonniek/mpv-playlistmanager/raw/master/playlistmanager.lua > scripts/playlistmanager.lua
curl -L https://github.com/mpv-player/mpv/raw/master/TOOLS/lua/ontop-playback.lua > scripts/ontop-playback.lua
curl -L https://github.com/occivink/mpv-scripts/raw/master/scripts/seek-to.lua > scripts/seek-to.lua
```
