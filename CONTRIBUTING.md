# Contributing Guide | 贡献指南

感谢关注 Open Omarchy！欢迎 Issue 与 PR。

Thanks for your interest in Open Omarchy! Issues and PRs are welcome.

## 如何添加发行版支持 | Adding a Distro

1. **`lib/detect.sh`** — 在 `detect_distro()` 的 case 中加入你的 `$ID`
2. **`lib/package-managers.sh`** — 在 `map_pkg()` 中补齐包名映射
   （apt 包名为基准；无对应包返回空字符串即可跳过）
3. **模块内家族差异** — 用 `require_family <debian|redhat|arch|suse>` 守卫，
   或 `case "$DISTRO_ID" in ...` 细分（参考 `modules/04-apps.sh` 的 Brave）
4. **优先级原则**：包管理器 > 官方仓库源 > GitHub 二进制回退
   （参考 `modules/03-dev-tools.sh` 的 lazygit）

## 模块约定 | Module Contract

- 自包含：每个模块开头 `source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"`，可独立运行
- 幂等：已安装的组件直接跳过（`command -v` 检查）
- 容错：单步失败用 `record_fail "描述"` 记录并继续，结尾必须调用 `module_summary`
- 不动桌面：绝不卸载或覆盖用户现有 DE/WM 的配置；dotfiles 已存在时不覆盖

## 代码风格 | Style

- Bash，`#!/usr/bin/env bash` + `set -u`（不用 `set -e`，容错由 record_fail 承担）
- 缩进 4 空格；函数命名 snake_case
- 用户可见文案使用中英任一，保持模块内一致
- 提交信息格式: `<type>: <摘要>`（feat/fix/docs/refactor/test/chore）

## 测试 | Testing

改动机器级脚本请先在容器验证：

```bash
# Ubuntu 22.04 全新容器实测
docker run -it --rm -v "$PWD":/repo ubuntu:22.04 bash
apt update && apt install -y sudo curl git ca-certificates bash
cd /repo && OPENOMARCHY_YES=1 ./install.sh dev
```

```bash
# Fedora 容器
docker run -it --rm -v "$PWD":/repo fedora:40 bash
dnf install -y sudo curl git && cd /repo && OPENOMARCHY_YES=1 ./install.sh dev
```

静态检查（提交前必做）：

```bash
for f in install.sh lib/*.sh modules/*.sh; do bash -n "$f"; done
```

## 报告 Bug | Reporting Bugs

请附上：发行版与版本（`cat /etc/os-release`）、安装模式、完整终端输出、
期望行为与实际行为。

## 许可证 | License

提交即表示同意以 [MIT](LICENSE) 许可发布。
