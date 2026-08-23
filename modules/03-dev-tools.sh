#!/usr/bin/env bash
# 模块 03 — 开发环境 (Neovim / Lazygit / Docker / Node.js(nvm) / GitHub CLI)
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"

step "[03-dev-tools] 安装 Neovim (PPA 最新稳定版) 与 Python 支持..."
pkg_install neovim python3-pip python3-venv || record_fail "Neovim 安装"

if command -v lazygit >/dev/null 2>&1; then
    ok "Lazygit 已存在"
elif pkg_install lazygit >/dev/null 2>&1 && command -v lazygit >/dev/null 2>&1; then
    ok "Lazygit 已通过包管理器安装"   # Fedora 39+ / Arch 等
else
    step "[03-dev-tools] 安装 Lazygit (最新版二进制)..."
    LAZYGIT_VERSION="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep -Po '"tag_name": "v\K[^"]*')" || true
    if [ -n "$LAZYGIT_VERSION" ]; then
        if wget -qO /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"; then
            tar -xzf /tmp/lazygit.tar.gz -C /tmp \
                && $SUDO install /tmp/lazygit /usr/local/bin/ \
                && ok "Lazygit ${LAZYGIT_VERSION} 已安装" \
                || record_fail "解压/安装 Lazygit"
        else
            record_fail "下载 Lazygit"
        fi
    else
        record_fail "获取 Lazygit 最新版本号 (GitHub API 限流?)"
    fi
fi

if command -v docker >/dev/null 2>&1; then
    ok "Docker 已存在"
else
    step "[03-dev-tools] 安装 Docker (官方脚本)..."
    curl -fsSL https://get.docker.com | sh || record_fail "Docker 安装"
    $SUDO usermod -aG docker "$USER" 2>/dev/null \
        && warn "已加入 docker 组 — 需重新登录后免 sudo 使用"
fi

if [ -d "$HOME/.nvm" ]; then
    ok "nvm 已存在"
else
    step "[03-dev-tools] 安装 nvm + Node.js LTS..."
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts || record_fail "Node.js LTS 安装 (重开终端后手动: nvm install --lts)"
    else
        record_fail "nvm 安装"
    fi
fi

step "[03-dev-tools] 安装 GitHub CLI..."
if command -v gh >/dev/null 2>&1; then
    ok "gh 已存在"
elif pkg_install gh >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then
    ok "gh 已通过包管理器安装"   # Fedora / Arch / openSUSE 均已收录
elif require_family debian; then
    # Debian 系老版本仓库缺 gh → 官方 apt 源回退
    if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | $SUDO tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && pkg_update && pkg_install gh \
            || record_fail "GitHub CLI 安装"
    else
        record_fail "下载 GitHub CLI 签名密钥"
    fi
fi

module_summary
