#!/bin/bash
# Open Omarchy - 一键安装脚本
# 将 Omarchy 的开发工具链和配置移植到 Linux Mint / Ubuntu

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# 打印函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "========================================="
    echo "  $1"
    echo "========================================="
}

# 检测发行版
detect_distro() {
    print_info "检测系统发行版..."
    
    if grep -qi "ubuntu" /etc/os-release; then
        DISTRO="ubuntu"
        print_success "检测到 Ubuntu"
    elif grep -qi "linuxmint\|mint" /etc/os-release; then
        DISTRO="mint"
        print_success "检测到 Linux Mint"
    elif grep -qi "debian" /etc/os-release; then
        DISTRO="debian"
        print_success "检测到 Debian"
    else
        print_error "此脚本目前仅支持 Ubuntu/Debian/Linux Mint 系发行版"
        print_error "你的系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
        exit 1
    fi
}

# 检查是否以 root 运行
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "检测到以 root 用户运行，建议使用普通用户（有 sudo 权限）执行"
        read -p "是否继续？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查网络连接 (ICMP 常被防火墙拦截, ping 失败时用 HTTPS 复核)
check_network() {
    print_info "检查网络连接..."
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        print_success "网络连接正常"
    elif curl -sI --max-time 5 https://github.com &> /dev/null; then
        print_warning "ping 不通但 HTTPS 可用（防火墙拦截 ICMP），继续安装"
    else
        print_error "网络连接失败，请检查网络后重试"
        exit 1
    fi
}

# 显示欢迎信息
show_welcome() {
    clear
    echo "╔═══════════════════════════════════════════╗"
    echo "║                                         ║"
    echo "║     Open Omarchy 一键安装脚本 v1.0      ║"
    echo "║                                         ║"
    echo "║  将 Omarchy 的开发工具链和配置移植到    ║"
    echo "║      Linux Mint / Ubuntu 系统           ║"
    echo "║                                         ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""
    echo "📖 项目主页: https://github.com/lightningasic/openomarchy"
    echo ""
}

# 选择安装模式
select_install_mode() {
    echo "请选择安装模式："
    echo "  1) 完整安装（推荐）- 安装所有工具和配置"
    echo "  2) 仅开发工具 - 安装 CLI 工具和开发环境"
    echo "  3) 仅配置文件 - 只部署 dotfiles 配置"
    echo "  4) 自定义 - 手动选择要安装的模块"
    echo ""
    read -p "请输入选项 [1-4]: " MODE
    
    case $MODE in
        1) SELECTED_MODULES="00-system 01-zram 02-cli-tools 03-dev-tools 04-apps 05-dotfiles" ;;
        2) SELECTED_MODULES="00-system 02-cli-tools 03-dev-tools" ;;
        3) SELECTED_MODULES="00-system 05-dotfiles" ;;
        4) select_custom_modules ;;
        *) print_error "无效选项"; exit 1 ;;
    esac
}

# 自定义模块选择
select_custom_modules() {
    echo ""
    echo "可用模块："
    echo "  a) 系统更新与基础依赖"
    echo "  b) ZRAM 内存压缩优化"
    echo "  c) CLI 工具 (fzf, ripgrep, zoxide, etc.)"
    echo "  d) 开发工具 (Neovim, Docker, Node.js)"
    echo "  e) 日常应用 (Brave, OnlyOffice, Obsidian)"
    echo "  f) 配置文件 (dotfiles)"
    echo ""
    read -p "请输入要安装的模块 (如: a b c): " INPUT
    
    SELECTED_MODULES=""
    for m in $INPUT; do
        case $m in
            a) SELECTED_MODULES="$SELECTED_MODULES 00-system" ;;
            b) SELECTED_MODULES="$SELECTED_MODULES 01-zram" ;;
            c) SELECTED_MODULES="$SELECTED_MODULES 02-cli-tools" ;;
            d) SELECTED_MODULES="$SELECTED_MODULES 03-dev-tools" ;;
            e) SELECTED_MODULES="$SELECTED_MODULES 04-apps" ;;
            f) SELECTED_MODULES="$SELECTED_MODULES 05-dotfiles" ;;
            *) print_warning "忽略未知选项: $m" ;;
        esac
    done
    
    if [ -z "$SELECTED_MODULES" ]; then
        print_error "未选择任何模块"
        exit 1
    fi
}

# 执行模块 (容错: 单个模块失败记录后继续, 结束时统一汇报)
run_modules() {
    print_header "开始安装 Open Omarchy"
    FAILED_MODULES=""

    for module in $SELECTED_MODULES; do
        MODULE_FILE="$MODULES_DIR/$module.sh"
        if [ ! -f "$MODULE_FILE" ]; then
            print_error "找不到模块文件: $MODULE_FILE"
            exit 1
        fi
        print_info "执行模块: $module"
        # 子 shell 运行, 避免 set -e 在模块内部直接终止整个安装器
        if bash "$MODULE_FILE"; then
            print_success "模块 $module 完成"
        else
            print_error "模块 $module 存在失败项（详见上方日志）"
            FAILED_MODULES="$FAILED_MODULES $module"
        fi
    done
}

# 完成信息
show_complete() {
    echo ""
    print_header "🎉 安装完成！"
    echo ""
    echo "已安装的模块："
    for module in $SELECTED_MODULES; do
        echo "  ✅ $module"
    done
    if [ -n "$FAILED_MODULES" ]; then
        echo ""
        print_warning "以下模块存在失败项，请回看上方日志后重试:$FAILED_MODULES"
    fi
    echo ""
    echo "💡 建议："
    echo "  1. 重启系统使所有更改生效: sudo reboot"
    echo "  2. Neovim 当前为基础配置，插件体系将在后续版本引入"
    echo "  3. 查看文档: https://github.com/lightningasic/openomarchy"
    echo ""
    echo "🐛 遇到问题？请提交 Issue:"
    echo "   https://github.com/lightningasic/openomarchy/issues"
    echo ""
}

# 主函数
main() {
    show_welcome
    check_root
    detect_distro
    check_network
    select_install_mode
    
    echo ""
    print_warning "即将安装以下模块: $SELECTED_MODULES"
    read -p "是否继续？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消安装"
        exit 0
    fi
    
    run_modules
    show_complete
}

# 执行主函数
main "$@"
