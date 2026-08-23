# Open Omarchy

> **English | [中文](#中文版)**

## English Version

### One-Sentence Description

**Open Omarchy** is a portable, cross-distribution configuration framework that brings Omarchy's curated developer toolchain and performance tuning to any mainstream Linux — while freeing you from its keyboard-only prison.

### The Philosophy

> *"Omarchy's design, which forces keyboard-only operation and treats the mouse, touchscreen, and keyboard as mutually exclusive choices, is simply inelegant."*

Omarchy is brilliant in its software selection and system optimisation, but its radical keyboard-centric dogma creates an unnecessary barrier for most users.

**Open Omarchy** is a graceful deconstruction:

- Preserves the **best of Omarchy** — hand-picked CLI tools, Neovim config, ZRAM, sysctl tuning
- Integrates seamlessly with **your existing desktop** — GNOME, KDE, Cinnamon, Xfce, or any other
- Offers **Hyprland** as an optional lightweight mode for those who love tiling WMs (roadmap)
- **Works on every major Linux distribution** — Debian, Ubuntu, Fedora, Arch, openSUSE, and more

**We believe the best interface is the one you choose — not the one forced upon you.**

### What's Inside

| Category | Tools & Features |
| - | - |
| **CLI Power-Tools** | `fzf`, `ripgrep`, `zoxide`, `eza`, `bat`, `btop`, `starship`, `tldr` |
| **Development Suite** | Neovim (pre-configured), Docker, Node.js (via nvm), Lazygit, GitHub CLI |
| **Everyday Apps** | Brave Browser, OnlyOffice, Obsidian, Spotify |
| **Performance Boost** | ZRAM (compressed swap), kernel `sysctl` optimisations |
| **Dotfiles** | Ready-to-use configurations for Neovim, Zsh, Tmux, Alacritty |

### Supported Distributions

| Family | Distributions | Status |
| - | - | - |
| **Debian** | Debian 11+, Ubuntu 20.04+, Linux Mint 21+, Pop!\_OS | Implemented |
| **Red Hat** | Fedora 38+, RHEL 9+, CentOS Stream 9+ | Implemented |
| **Arch** | Arch Linux, Manjaro, EndeavourOS, Garuda | Implemented |
| **SUSE** | openSUSE Leap 15.4+, Tumbleweed | Implemented |

### Quick Start

```bash
git clone https://github.com/lightningasic/openomarchy.git
cd openomarchy
chmod +x install.sh
./install.sh            # interactive
./install.sh dev -y     # non-interactive (also: OPENOMARCHY_YES=1)
```

The installer detects your distribution and offers four modes:

1. **Full Installation** — all tools, optimisations, and dotfiles (recommended)
2. **Developer Tools Only** — CLI + development environment
3. **Dotfiles Only** — just the configuration files
4. **Custom** — pick individual modules

### Architecture

```
openomarchy/
├── install.sh              # Main installer (4 modes)
├── modules/                # Independent modules
│   ├── 00-system.sh        # System update & base dependencies (+ Neovim PPA)
│   ├── 01-zram.sh          # ZRAM configuration + sysctl tuning
│   ├── 02-cli-tools.sh     # CLI tools (fixes bat/fd alias trap)
│   ├── 03-dev-tools.sh     # Neovim / Lazygit / Docker / nvm / gh
│   ├── 04-apps.sh          # Brave / Obsidian / OnlyOffice / Spotify
│   └── 05-dotfiles.sh      # Dotfile deployment (offline, built-in)
├── lib/                    # Distribution adapters
│   ├── detect.sh           # OS detection + logging/failure tracking
│   └── package-managers.sh # Generic package name -> apt/dnf/pacman/zypper
├── configs/                # System templates (zramswap/sysctl/Hyprland)
├── dotfiles/               # Pre-configured user configs
├── README.md
└── LICENSE
```

- **Distribution detection** automatically identifies your system.
- **Package abstraction** translates generic commands (`pkg_install build-essential`) into the correct package-manager syntax and names.
- **Desktop-aware** — leaves your existing GUI untouched unless you explicitly choose Hyprland.
- **Fault-tolerant** — every step is tracked; failures are reported clearly instead of dying halfway.

### Roadmap

- [x] Core concept & design
- [x] Linux Mint / Ubuntu implementation
- [x] Add Fedora / RHEL support
- [x] Add Arch / Manjaro support
- [x] Add openSUSE support
- [ ] NixOS flake integration
- [x] Optional Hyprland mode (experimental)
- [ ] Graphical installer (optional)
- [ ] User-contributed dotfiles repository

### Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) before submitting issues or pull requests.

### License

MIT License — see [LICENSE](LICENSE) for details.

---

## 中文版

### 一句话介绍

**Open Omarchy** 是一个可移植、跨发行版的配置框架，它将 Omarchy 精挑细选的开发者工具链和性能优化方案带到所有主流 Linux 上，同时让你摆脱其"纯键盘操作"的桎梏。

### 核心理念

> "Omarchy 完全采用键盘操作，将鼠标、触摸屏与键盘作为互相排斥的选项，是不优雅的设计。"

Omarchy 在软件选型和系统优化上非常出色，但其极端的"键盘原教旨主义"给大部分用户制造了不必要的门槛。

**Open Omarchy** 是对它的"优雅解构"：

- 保留 Omarchy 的**精华**：精选 CLI 工具、Neovim 配置、ZRAM 压缩内存、系统参数调优
- **无缝融入你现有的桌面环境**：GNOME、KDE、Cinnamon、Xfce……均可共存
- **Hyprland 作为可选轻量模式**（路线图）：平铺窗口管理器爱好者可以一键启用
- **支持所有主流 Linux 发行版**：Debian、Ubuntu、Fedora、Arch、openSUSE 等

**我们相信，最好的交互方式是你可以自由选择的，而非被强制接受的。**

### 包含内容

| 类别 | 工具与特性 |
| - | - |
| **CLI 效率工具** | `fzf`、`ripgrep`、`zoxide`、`eza`、`bat`、`btop`、`starship`、`tldr` |
| **开发环境** | Neovim（预配置）、Docker、Node.js（通过 nvm）、Lazygit、GitHub CLI |
| **日常应用** | Brave 浏览器、OnlyOffice、Obsidian 笔记、Spotify |
| **性能优化** | ZRAM 压缩交换分区、内核 `sysctl` 参数调优 |
| **配置文件 (Dotfiles)** | Neovim、Zsh、Tmux、Alacritty 的即用配置 |

### 支持的发行版

| 家族 | 具体发行版 | 状态 |
| - | - | - |
| **Debian 系** | Debian 11+、Ubuntu 20.04+、Linux Mint 21+、Pop!\_OS | 已实现 |
| **Red Hat 系** | Fedora 38+、RHEL 9+、CentOS Stream 9+ | 已实现 |
| **Arch 系** | Arch Linux、Manjaro、EndeavourOS、Garuda | 已实现 |
| **SUSE 系** | openSUSE Leap 15.4+、Tumbleweed | 已实现 |

### 快速开始

```bash
git clone https://github.com/lightningasic/openomarchy.git
cd openomarchy
chmod +x install.sh
./install.sh            # 交互式
./install.sh dev -y     # 非交互式（或 OPENOMARCHY_YES=1）
```

安装程序会自动检测你的发行版，并提供四种安装模式：

1. **完整安装** – 全部工具、优化和配置文件（推荐）
2. **仅开发工具** – CLI 工具 + 开发环境
3. **仅配置文件** – 只部署 dotfiles
4. **自定义** – 手动选择要安装的模块

### 技术架构

```
openomarchy/
├── install.sh              # 主安装脚本（4 种模式）
├── modules/                # 独立模块
│   ├── 00-system.sh        # 系统更新与基础依赖（含 Neovim PPA）
│   ├── 01-zram.sh          # ZRAM 配置 + 内核参数调优
│   ├── 02-cli-tools.sh     # CLI 工具（解决 bat/fd 别名陷阱）
│   ├── 03-dev-tools.sh     # Neovim / Lazygit / Docker / nvm / gh
│   ├── 04-apps.sh          # Brave / Obsidian / OnlyOffice / Spotify
│   └── 05-dotfiles.sh      # 配置文件部署（离线内置）
├── lib/                    # 发行版适配层
│   ├── detect.sh           # 发行版检测 + 日志/失败记录
│   └── package-managers.sh # 通用包名 → apt/dnf/pacman/zypper 翻译
├── configs/                # 系统模板（zramswap/sysctl/Hyprland）
├── dotfiles/               # 预置的用户配置
├── README.md
└── LICENSE
```

- **发行版自动检测** – 准确识别你的系统。
- **包管理抽象** – 将通用指令（如 `pkg_install build-essential`）自动翻译为目标发行版的包管理器命令与包名。
- **桌面友好** – 除非你明确选择 Hyprland，否则不会干预你现有的图形界面。
- **容错设计** – 每个步骤都有失败记录，出错时清晰提示而不是半死不活。

### 路线图

- [x] 核心理念与设计
- [x] Linux Mint / Ubuntu 实现
- [x] 增加 Fedora / RHEL 支持
- [x] 增加 Arch / Manjaro 支持
- [x] 增加 openSUSE 支持
- [ ] NixOS flake 集成
- [x] 可选 Hyprland 模式（实验性）
- [ ] 图形化安装界面（可选）
- [ ] 社区贡献的 dotfiles 仓库

### 贡献指南

欢迎贡献代码或建议！提交 Issue 或 Pull Request 前，请阅读[贡献指南](CONTRIBUTING.md)。

### 许可证

MIT 许可证 – 详见 [LICENSE](LICENSE) 文件。

---

*Open Omarchy – 优雅地解构，自由地选择。*
