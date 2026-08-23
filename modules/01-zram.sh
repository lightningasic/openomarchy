#!/usr/bin/env bash
# 模块 01 — ZRAM 压缩交换 + 内核参数调优 (Omarchy 性能精华)
set -u
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MOD_DIR/../lib/detect.sh"
PROJECT_ROOT="$(dirname "$MOD_DIR")"

step "[01-zram] 配置 ZRAM 压缩交换..."

if require_family debian; then
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

    step "[01-zram] 应用内核参数调优 (vm.swappiness 等)..."
    if $SUDO cp "$PROJECT_ROOT/configs/99-openomarchy.conf" /etc/sysctl.d/ 2>/dev/null; then
        $SUDO sysctl --system >/dev/null 2>&1 \
            && ok "内核参数已生效 (完整效果建议重启)" \
            || warn "sysctl 刷新失败, 重启后自动生效"
    else
        record_fail "复制 sysctl 配置"
    fi
fi

module_summary
