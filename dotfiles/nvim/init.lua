-- Open Omarchy 基础 Neovim 配置 (最小可用版; 插件体系第二阶段引入)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus'

-- 快捷键 (leader 键: 空格)
vim.g.mapleader = ' '
-- 以下快捷键依赖 NvimTree/Telescope, 第二阶段插件安装后自动生效
pcall(function()
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
    vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
end)

print("Open Omarchy Neovim config loaded!")
