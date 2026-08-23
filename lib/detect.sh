#!/usr/bin/env bash
# ============================================================================
# Open Omarchy — 发行版检测 + 日志/错误处理基础设施
# 被 install.sh 与各模块 source, 提供:
#   变量: DISTRO_ID / DISTRO_NAME / DISTRO_VERSION / PKG_MANAGER / SUDO
#   函数: pkg_install / pkg_update / pkg_upgrade / pkg_remove (lib/package-managers.sh)
#         step / ok / warn / die / record_fail / module_summary / require_family
# ============================================================================

# ---- 权限: 容器内可直接 root 运行, 普通用户走 sudo ----
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || { echo "❌ 需要 root 权限或安装 sudo"; exit 1; }
    SUDO="sudo"
fi

# ---- 日志与失败记录 ----
step() { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✅ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m⚠️  %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m❌ %s\033[0m\n' "$*" >&2; exit 1; }

MODULE_FAILURES=()
record_fail() {
    MODULE_FAILURES+=("$*")
    warn "步骤失败: $* (跳过并继续)"
}
module_summary() {
    if [ ${#MODULE_FAILURES[@]} -gt 0 ]; then
        warn "$(basename "${BASH_SOURCE[1]}") 完成但存在失败项:"
        local f
        for f in "${MODULE_FAILURES[@]}"; do echo "   - $f"; done
        return 1
    fi
    return 0
}

# 发行版家族守卫: require_family debian — 非该家族则返回 1 (模块自行跳过)
require_family() {
    case "$1" in
        debian) case "$DISTRO_ID" in ubuntu|linuxmint|debian|pop) return 0 ;; esac ;;
        redhat) case "$DISTRO_ID" in fedora|rhel|centos) return 0 ;; esac ;;
        arch)   case "$DISTRO_ID" in arch|manjaro|endeavouros|garuda) return 0 ;; esac ;;
        suse)   case "$DISTRO_ID" in opensuse*) return 0 ;; esac ;;
    esac
    warn "当前发行版 ($DISTRO_ID) 暂不支持此步骤, 跳过"
    return 1
}

# ---- 发行版检测 ----
detect_distro() {
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        export DISTRO_ID="${ID:-unknown}"
        export DISTRO_NAME="${NAME:-unknown}"
        export DISTRO_VERSION="${VERSION_ID:-unknown}"
    else
        die "无法检测发行版 (/etc/os-release 不存在)"
    fi

    case "$DISTRO_ID" in
        ubuntu|linuxmint|debian|pop)
            export PKG_MANAGER="apt"
            ;;
        fedora|rhel|centos)
            export PKG_MANAGER="dnf"
            ;;
        arch|manjaro|endeavouros|garuda)
            export PKG_MANAGER="pacman"
            ;;
        opensuse*|sles)
            export PKG_MANAGER="zypper"
            ;;
        *)
            die "不支持的发行版: $DISTRO_ID"
            ;;
    esac

    # 包管理命令抽象 (lib/package-managers.sh)
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package-managers.sh"

    ok "检测到: $DISTRO_NAME ($DISTRO_ID), 包管理器: $PKG_MANAGER"
}
