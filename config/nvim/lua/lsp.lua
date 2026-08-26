vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.lsp.enable('bashls')
vim.lsp.enable('ccls')
vim.lsp.enable('neocmake')
vim.lsp.enable('jsonls')
vim.lsp.enable('html')
vim.lsp.enable('cssls')

