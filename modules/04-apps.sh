#!/usr/bin/env bash
# 模块 04 — 日常应用 (Brave / Obsidian / OnlyOffice / Spotify)
# 原则: 不动现有桌面环境; 每个应用独立容错, 失败不影响其他应用。
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"

install_brave() {
    command -v brave-browser >/dev/null 2>&1 && { ok "Brave 已存在"; return 0; }
    step "[04-apps] 安装 Brave 浏览器 (官方 apt 源)..."
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
        | $SUDO dd of=/usr/share/keyrings/brave-browser-archive-keyring.gpg 2>/dev/null \
        || { record_fail "下载 Brave 签名密钥"; return 1; }
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | $SUDO tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null \
        || { record_fail "写入 Brave 源"; return 1; }
    pkg_update && pkg_install brave-browser || record_fail "安装 brave-browser"
}

install_obsidian() {
    command -v obsidian >/dev/null 2>&1 && { ok "Obsidian 已存在"; return 0; }
    step "[04-apps] 安装 Obsidian (官方 deb 最新版)..."
    local url
    url="$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
        | grep -o 'https://[^"]*amd64\.deb' | head -n1)"
    if [ -n "$url" ]; then
        wget -qO /tmp/obsidian.deb "$url" \
            && $SUDO apt-get install -y /tmp/obsidian.deb \
            && ok "Obsidian 已安装" \
            || record_fail "安装 Obsidian"
    else
        record_fail "获取 Obsidian 下载地址 (GitHub API 限流?)"
    fi
}

ensure_flatpak() {
    command -v flatpak >/dev/null 2>&1 || pkg_install flatpak || { record_fail "安装 flatpak"; return 1; }
    flatpak remotes | grep -q flathub || $SUDO flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
        || { record_fail "添加 Flathub 源"; return 1; }
    return 0
}

if require_family debian; then
    install_brave
    install_obsidian

    step "[04-apps] 通过 Flatpak 安装 OnlyOffice + Spotify..."
    if ensure_flatpak; then
        flatpak install -y --noninteractive flathub org.onlyoffice.desktopeditors \
            || record_fail "安装 OnlyOffice"
        flatpak install -y --noninteractive flathub com.spotify.Client \
            || record_fail "安装 Spotify"
        warn "Flatpak 应用首次出现在应用菜单可能需要注销/重启桌面"
    fi
fi

module_summary
