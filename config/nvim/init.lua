require("lsp")

vim.opt.number = true
vim.opt.relativenumber = true

vim.cmd([[
    set encoding=utf-8 fileencodings=
    syntax on

    set list listchars=tab:»·,trail:·
    set cc=80
    set expandtab sw=4 sts=4
]])
