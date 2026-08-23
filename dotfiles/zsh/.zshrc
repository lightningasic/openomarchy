# Open Omarchy Zsh 配置
export PATH="$HOME/.local/bin:$PATH"

# oh-my-zsh (由 05-dotfiles 预装; 缺失时静默自装一次)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1
fi
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(git z extract)
  source "$ZSH/oh-my-zsh.sh"
fi

# Starship 提示符 (存在则优先于 omz 主题)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# 别名 (适配 Ubuntu/Mint 包名差异: bat->batcat, fd->fdfind)
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# Zoxide 智能目录跳转
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf 快捷键 + 补全
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh 2>/dev/null || fzf --bash) 2>/dev/null
fi
