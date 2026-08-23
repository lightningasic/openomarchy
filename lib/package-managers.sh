#!/usr/bin/env bash
# ============================================================================
# Open Omarchy — 包管理抽象层
# 将通用包名翻译为目标发行版的包管理器命令。
# 由 lib/detect.sh 在 detect_distro() 末尾 source, 依赖 $PKG_MANAGER / $SUDO。
# ============================================================================

# map_pkg <通用包名> — 输出映射后的包名 (可为多个词), 空输出 = 该发行版跳过
# apt 包名作为基准命名
map_pkg() {
    local p="$1"
    case "$PKG_MANAGER:$p" in
        # ---- Debian 系: 原名直用 ----
        apt:*) echo "$p" ;;
        # ---- Red Hat 系 ----
        dnf:build-essential)            echo "gcc gcc-c++ make" ;;
        dnf:software-properties-common) echo "" ;;
        dnf:apt-transport-https)        echo "" ;;
        dnf:lsb-release)                echo "" ;;
        dnf:python3-venv)               echo "" ;;
        dnf:gnupg)                      echo "gnupg2" ;;
        dnf:zram-tools)                 echo "zram" ;;
        # ---- Arch 系 ----
        pacman:build-essential)         echo "base-devel" ;;
        pacman:software-properties-common|pacman:apt-transport-https|pacman:lsb-release|pacman:python3-venv)
                                        echo "" ;;
        pacman:fd-find)                 echo "fd" ;;
        pacman:tldr)                    echo "tealdeer" ;;
        pacman:zram-tools)              echo "zram-generator" ;;
        pacman:epel-release)            echo "" ;;
        # ---- SUSE 系 ----
        zypper:build-essential)         echo "gcc gcc-c++ make" ;;
        zypper:software-properties-common|zypper:apt-transport-https|zypper:lsb-release|zypper:python3-venv)
                                        echo "" ;;
        zypper:gnupg)                   echo "gpg2" ;;
        zypper:epel-release)            echo "" ;;
        zypper:zram-tools)              echo "zram-generator" ;;
        # ---- 兜底: 同名 ----
        *) echo "$p" ;;
    esac
}

pkg_install() {
    local mapped=() p m
    for p in "$@"; do
        m="$(map_pkg "$p")"
        [ -n "$m" ] && mapped+=($m)   # 有意分词: 一个通用名可映射为多个包
    done
    [ ${#mapped[@]} -eq 0 ] && return 0
    case "$PKG_MANAGER" in
        apt)    $SUDO apt-get install -y "${mapped[@]}" ;;
        dnf)    $SUDO dnf install -y "${mapped[@]}" ;;
        pacman) $SUDO pacman -S --needed --noconfirm "${mapped[@]}" ;;
        zypper) $SUDO zypper install -y "${mapped[@]}" ;;
    esac
}

pkg_update() {
    case "$PKG_MANAGER" in
        apt)    $SUDO apt-get update ;;
        dnf)    $SUDO dnf check-update; return 0 ;;  # check-update 非零仅代表有更新
        pacman) $SUDO pacman -Sy ;;
        zypper) $SUDO zypper refresh ;;
    esac
}

pkg_upgrade() {
    case "$PKG_MANAGER" in
        apt)    $SUDO apt-get upgrade -y ;;
        dnf)    $SUDO dnf upgrade -y ;;
        pacman) $SUDO pacman -Syu --noconfirm ;;
        zypper) $SUDO zypper update -y ;;
    esac
}

pkg_remove() {
    local mapped=() p m
    for p in "$@"; do
        m="$(map_pkg "$p")"
        [ -n "$m" ] && mapped+=($m)
    done
    [ ${#mapped[@]} -eq 0 ] && return 0
    case "$PKG_MANAGER" in
        apt)    $SUDO apt-get remove -y "${mapped[@]}" ;;
        dnf)    $SUDO dnf remove -y "${mapped[@]}" ;;
        pacman) $SUDO pacman -R --noconfirm "${mapped[@]}" ;;
        zypper) $SUDO zypper remove -y "${mapped[@]}" ;;
    esac
}
