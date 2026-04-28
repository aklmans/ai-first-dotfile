# Migration Report: wow-dotfile-v2 to ai-first-dotfile

## 基本信息

- 新仓库路径：`$HOME/Workspace/Projects/workflow/ai-first-dotfile`
- 旧仓库路径：`$HOME/Workspace/Projects/workflow/wow-dotfile-v2`（仅只读扫描）
- Git 远端：`origin -> git@github.com:aklmans/ai-first-dotfile.git`
- 当前分支：`main`
- 当前 HEAD：本次提交（待发布前最终提交）
- 迁移策略：不携带旧 `.git`、不保留旧历史，按模块多次提交重建干净 commit history。

## Commit 历史与范围

按模块顺序的提交如下（已完成）：

1. `6a50e50` `docs: add clean migration plan`
2. `28b225c` `chore: initialize clean dotfile repository`
3. `5513e29` `chore: add bootstrap installers and manifests`
4. `38f3e36` `feat: add zsh and starship shell environment`
5. `9688059` `feat: add terminal and file manager configs`
6. `4d0f5e8` `feat: add aerospace workspace management`
7. `083849c` `feat: add sketchybar and borders desktop UI`
8. `61b67ca` `feat: add bettertouchtool workspace gestures`
9. `57e4559` `feat: add hammerspoon automation`
10. `bee1468` `feat: add capslock ai lite karabiner profile`
11. `015e7ea` `feat: add ai workflow router core`
12. `05255b7` `feat: add ai router prompts snippets and tests`
13. `b7dc381` `feat: add editor media and app configs`
14. `996a607` `docs: add workflow and migration documentation`
15. `267d17c` `test: add repository smoke and privacy checks`
16. （本次提交）`docs: add migration report`

## 阶段 14 变更（仓库检查和隐私保障）

- 新增 `tests/smoke/install_script_syntax_smoke.sh`
- 新增 `tests/smoke/repository_structure_smoke.sh`
- 新增 `tests/smoke/install_script_side_effects_smoke.sh`
- 新增 `tests/smoke/privacy_scan_smoke.sh`
- 更新 `.gitignore`：
  - 增加 `**/__pycache__/`
  - 补强运行时/私有信息隔离规则（沿用现有已增强清单）
- 调整 `README.md` 与 `MIGRATION_PLAN.md` 中旧仓库路径为 `$HOME` 语义占位，避免硬编码用户绝对路径。

## 阶段 3 验证与扫描结果

执行命令（已通过）：

- `bash -n bootstrap/lib/common.sh`
- `bash -n tests/smoke/install_script_syntax_smoke.sh`
- `bash -n tests/smoke/install_script_side_effects_smoke.sh`
- `bash -n tests/smoke/privacy_scan_smoke.sh`
- `bash -n tests/smoke/repository_structure_smoke.sh`
- `bash tests/smoke/install_script_syntax_smoke.sh`
- `bash tests/smoke/install_script_side_effects_smoke.sh`
- `bash tests/smoke/repository_structure_smoke.sh`
- `bash tests/smoke/ai_router_exports_smoke.sh`
- `HOME="$PWD/home" bash home/.config/ai-router/tests/run.sh`
- `HOME="$PWD/home" bash tests/smoke/privacy_scan_smoke.sh`（完整隐私 smoke）
- `python3 -m json.tool home/.config/karabiner/karabiner.json`
- `git diff --check`

额外全量扫描：

- `rg -n "api[_-]?key|secret|token|password|passwd|cookie|session|sk-|ghp_|github_pat|BEGIN .*KEY|OPENAI|ANTHROPIC|GEMINI|KIMI|AWS|PRIVATE KEY" .`
  - 仅命中文档说明文本与脚本注释中的关键词；未命中可疑高置信 token。
- `gitleaks detect --no-git --source .`
  - 工具缺失（未安装）。
- `trufflehog filesystem .`
  - 工具缺失（未安装）。

### 结论

- Stage 14 smoke 与脚本语法检查全部通过；
- `private/cache/logs/state/catalogs`、遗留工具目录及 `warp-launch-agent` 在仓库检查中都不存在；
- `karabiner.json` 与 `router_tools.py` 均通过语法校验；
- 关键 AI Router 导出漂移检测通过（`ai_router_exports_smoke`）。

## 隐私处理记录

已处理/排除项：

- 未迁移：`home/.config/skhd` / `home/.config/yabai` / `home/.config/wezterm` / `home/.config/oh-my-posh`
- 未迁移：`home/.config/aerospace/warp-launch-agent.sh`
- 未迁移：`bootstrap/install/warp-launch-agent.sh`
- 未迁移：`home/.config/ai-router/{cache,logs,state,catalogs}`
- 未迁移：Obsidian 私有工作区/运行时/会话（仅保留公开友好设置）
- 未迁移：`.env*`、`*.bak`、`*.backup*`、历史 backup 文件与临时文件（在迁移清单中排除）
- `README.md` 与 `MIGRATION_PLAN.md` 中旧路径已替换为 `$HOME/...` 形式。

待确认项：

- 未扫描旧仓库 Git history（按要求不重建历史）；若未来在旧 history 中发现真实 token/凭据历史痕迹，请在旧环境中旋转相关口令。

## 后续建议

- 建议在公开环境中安装 `gitleaks`/`trufflehog` 后再跑一次全量扫描；
- 在后续变更中继续保持模块级别提交；
- 若新增 AI Router 提供商/路由输出，保持 `tests/smoke/ai_router_exports_smoke.sh` 为前置校验。
