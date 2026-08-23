#!/usr/bin/env bash
# 模块 01 — ZRAM 压缩交换 + 内核参数调优 (Omarchy 性能精华)
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"
PROJECT_ROOT="$(dirname "$MOD_DIR")"

step "[01-zram] 配置 ZRAM 压缩交换..."

apply_sysctl() {
    step "[01-zram] 应用内核参数调优 (vm.swappiness 等)..."
    if $SUDO cp "$PROJECT_ROOT/configs/99-openomarchy.conf" /etc/sysctl.d/ 2>/dev/null; then
        $SUDO sysctl --system >/dev/null 2>&1 \
            && ok "内核参数已生效 (完整效果建议重启)" \
            || warn "sysctl 刷新失败, 重启后自动生效"
    else
        record_fail "复制 sysctl 配置"
    fi
}

case "$DISTRO_ID" in
    ubuntu|linuxmint|debian|pop)
        # Debian 系: zram-tools + /etc/default/zramswap
        pkg_install zram-tools || record_fail "安装 zram-tools"

        if [ -f /etc/default/zramswap ]; then
            $SUDO cp "$PROJECT_ROOT/configs/zramswap" /etc/default/zramswap \
                && ok "ZRAM 参数已写入 (ALGO=zstd, PERCENT=50)" \
                || record_fail "写入 /etc/default/zramswap"
            $SUDO systemctl enable --now zramswap >/dev/null 2>&1 \
                && ok "zramswap 服务已启用" \
                || { $SUDO systemctl restart zramswap >/dev/null 2>&1 && ok "zramswap 服务已重启" \
                     || record_fail "启用 zramswap 服务"; }
        else
            record_fail "未找到 /etc/default/zramswap (zram-tools 未装上?)"
        fi
        ;;
    *)
        # Fedora/Arch/openSUSE: systemd 官方机制 zram-generator
        pkg_install zram-generator >/dev/null 2>&1 || record_fail "安装 zram-generator"
        if $SUDO cp "$PROJECT_ROOT/configs/zram-generator.conf" /etc/systemd/zram-generator.conf 2>/dev/null; then
            ok "zram-generator 配置已写入 (内存 50% / zstd)"
            $SUDO systemctl daemon-reload >/dev/null 2>&1
            $SUDO systemctl start systemd-zram-setup@zram0.service >/dev/null 2>&1 \
                && ok "ZRAM 设备已激活" \
                || warn "ZRAM 将在下次重启后自动激活 (当前会话可忽略)"
        else
            record_fail "写入 /etc/systemd/zram-generator.conf"
        fi
        ;;
esac

apply_sysctl
module_summary
