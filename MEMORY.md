# MEMORY — Open Omarchy 项目状态

## 已完成 (2026-08-24)

- **仓库**: https://github.com/lightningasic/openomarchy (deploy key: ~/.ssh/openomarchy-deploy, ssh 别名 github.com-openomarchy)
- **第一阶段** Linux Mint/Ubuntu 实现 + 推送 (a9fa716 → 4dbe0ce)
- **全发行版适配 + Hyprland 实验模式** 推送 (1808db5):
  - install.sh 非交互: `./install.sh <full|dev|dotfiles|custom>` + `-y` / `OPENOMARCHY_YES=1`
  - ZRAM 双机制: Debian 系 zram-tools / 其余 zram-generator (configs/zram-generator.conf)
  - eza/lazygit/gh: 包管理器优先 → GitHub 二进制/官方源回退
  - Brave apt+RPM 官方源; Obsidian deb+Flatpak; RHEL/CentOS 自动 EPEL
  - modules/06-hyprland.sh + configs/hyprland/{hyprland.conf,waybar.jsonc,waybar.css}
  - CONTRIBUTING.md (扩展发行版指南/模块约定/容器测试命令)

## 待办

1. **容器实测未做** — 本机无 docker 且内存吃紧。需在 VM/docker 跑:
   - `docker run -it --rm -v "$PWD":/repo ubuntu:22.04` → `OPENOMARCHY_YES=1 ./install.sh dev`
   - 同样跑 fedora:40 与 opensuse/tumbleweed 验证 dnf/zypper 路径
2. **路线图遗留** (README 未勾选): NixOS flake 集成、图形化安装界面、社区 dotfiles 仓库
3. Neovim 插件体系 (当前为基础配置, README 已如实标注)
4. Hyprland 模块待真机验证 (Debian 系因官方无包暂跳过)

## 注意事项

- 旧仓库 lightningasic/open-omarchy 已废弃, 所有链接统一 openomarchy
- 用户偏好: install.sh 保持其选定的结构 (print_info 风格), 只做最小必要修改
- 模块契约见 CONTRIBUTING.md: record_fail/module_summary 容错, 不用 set -e
