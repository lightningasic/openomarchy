#!/usr/bin/env bash
# 模块 06 — Hyprland 可选轻量模式 (实验性)
# 哲学: 不动现有桌面; 装完后在登录界面 (GDM/SDDM/LightDM) 会话菜单选择 Hyprland。
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"
PROJECT_ROOT="$(dirname "$MOD_DIR")"

warn "Hyprland 模式为实验性功能 — 不影响现有桌面环境"

case "$DISTRO_ID" in
    ubuntu|linuxmint|debian|pop)
        warn "Debian/Ubuntu/Mint 官方仓库尚未收录 Hyprland"
        warn "请参考 https://wiki.hyprland.org/Getting-Started/Installation/ 添加上游源后重跑本模块"
        module_summary
        exit 0
        ;;
esac

step "[06-hyprland] 安装 Wayland 栈 (hyprland/waybar/kitty/wofi/mako...)"
pkg_install hyprland waybar kitty wofi mako hyprpaper \
    xdg-desktop-portal-hyprland polkit-gnome \
    || record_fail "Wayland 组件安装"

step "[06-hyprland] 部署最小配置..."
mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar"
ln -sf "$PROJECT_ROOT/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf" \
    && echo "   链接: ~/.config/hypr/hyprland.conf"
ln -sf "$PROJECT_ROOT/configs/hyprland/waybar.jsonc" "$HOME/.config/waybar/config" \
    && echo "   链接: ~/.config/waybar/config"
ln -sf "$PROJECT_ROOT/configs/hyprland/waybar.css" "$HOME/.config/waybar/style.css" \
    && echo "   链接: ~/.config/waybar/style.css"

ok "部署完成 — 注销后在登录界面会话菜单选择 'Hyprland' 进入"
module_summary
