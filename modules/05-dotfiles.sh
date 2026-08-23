#!/usr/bin/env bash
# 模块 05 — 配置文件部署 (全部来自项目内置 dotfiles/, 离线可用)
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"
PROJECT_ROOT="$(dirname "$MOD_DIR")"
DOTFILES_SRC="$PROJECT_ROOT/dotfiles"

# 链接单个配置; 目标已存在且非链接时自动备份
link_config() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.backup.$(date +%s)"
        warn "已备份原文件: $dst → $dst.backup.*"
    fi
    ln -sf "$src" "$dst"
    echo "   链接: $dst → $src"
}

step "[05-dotfiles] 部署配置文件..."

# Neovim
mkdir -p "$HOME/.config/nvim"
link_config "$DOTFILES_SRC/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Zsh (不覆盖已有 .zshrc)
if [ ! -f "$HOME/.zshrc" ]; then
    link_config "$DOTFILES_SRC/zsh/.zshrc" "$HOME/.zshrc"
else
    warn "已存在 ~/.zshrc, 不覆盖 (可手动参考 $DOTFILES_SRC/zsh/.zshrc)"
fi

# Tmux
link_config "$DOTFILES_SRC/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Alacritty
mkdir -p "$HOME/.config/alacritty"
link_config "$DOTFILES_SRC/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# oh-my-zsh 预装 (.zshrc 内含兜底自装逻辑)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    step "[05-dotfiles] 安装 oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
        || record_fail "安装 oh-my-zsh (离线环境: .zshrc 会跳过该段)"
fi

# 默认 shell 切换 Zsh (chsh 可能要求输入密码)
if command -v zsh >/dev/null 2>&1 && [ "$SHELL" != "$(command -v zsh)" ]; then
    step "[05-dotfiles] 将默认 shell 切换为 Zsh..."
    chsh -s "$(command -v zsh)" \
        || warn "chsh 未完成 — 请稍后手动执行: chsh -s $(command -v zsh)"
fi

module_summary
