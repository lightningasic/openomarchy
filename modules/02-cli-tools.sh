#!/usr/bin/env bash
# 模块 02 — CLI 效率工具 (fzf/ripgrep/bat/eza/zoxide/starship/btop/tmux...)
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"

# ~/.local/bin 入 PATH (软链接落点)
ensure_local_bin() {
    mkdir -p "$HOME/.local/bin"
    case ":$PATH:" in *":$HOME/.local/bin:"*) return 0 ;; esac
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ] && ! grep -qs '\.local/bin' "$rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        fi
    done
}

step "[02-cli-tools] 安装 CLI 效率工具..."
pkg_install fzf ripgrep fd-find bat tree jq tldr tmux btop \
    || record_fail "发行版仓库 CLI 工具安装"

ensure_local_bin

# ---- Ubuntu/Mint 别名陷阱: bat->batcat, fd->fdfind, 软链接对齐 Omarchy 用法 ----
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    ok "已创建 bat 软链接 (batcat)"
fi
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "已创建 fd 软链接 (fdfind)"
fi

if command -v zoxide >/dev/null 2>&1; then
    ok "zoxide 已存在"
else
    step "[02-cli-tools] 安装 zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash \
        || record_fail "安装 zoxide"
fi

if command -v eza >/dev/null 2>&1; then
    ok "eza 已存在"
else
    step "[02-cli-tools] 安装 eza (官方 deb)..."
    if wget -qO /tmp/eza.deb "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.deb"; then
        $SUDO dpkg -i /tmp/eza.deb >/dev/null || $SUDO apt-get install -f -y \
            || record_fail "安装 eza"
    else
        record_fail "下载 eza deb"
    fi
fi

if command -v starship >/dev/null 2>&1; then
    ok "starship 已存在"
else
    step "[02-cli-tools] 安装 starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y \
        || record_fail "安装 starship"
fi

module_summary
