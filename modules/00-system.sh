#!/usr/bin/env bash
# 模块 00 — 系统更新与基础依赖
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"

step "[00-system] 更新软件源..."
pkg_update || record_fail "软件源更新 (检查网络/镜像源)"

step "[00-system] 升级已安装软件包..."
pkg_upgrade || record_fail "系统升级 (可稍后手动执行)"

step "[00-system] 安装基础依赖..."
pkg_install curl wget git vim htop build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release unzip zsh \
    || record_fail "基础依赖安装"

# RHEL/CentOS 需要 EPEL 才能安装 fzf/btop 等工具
case "$DISTRO_ID" in
    rhel|centos)
        pkg_install epel-release || record_fail "启用 EPEL 仓库"
        ;;
esac

# Neovim 官方稳定版 PPA (Ubuntu/Mint/Pop 专属)
case "$DISTRO_ID" in
    ubuntu|linuxmint|pop)
        if grep -rqs "neovim-ppa" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null; then
            ok "Neovim PPA 已存在, 跳过"
        else
            step "[00-system] 添加 Neovim 稳定版 PPA..."
            $SUDO add-apt-repository ppa:neovim-ppa/stable -y \
                && pkg_update \
                || record_fail "添加 Neovim PPA"
        fi
        ;;
esac

module_summary
