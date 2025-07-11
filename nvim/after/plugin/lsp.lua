require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "bashls",
        "phpactor",
        "html",
        "texlab"
    }
})

-- Setup diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Setup lspconfig
local lspconfig = require("lspconfig")

-- Setup clangd
lspconfig.clangd.setup({})

-- Setup bashls
lspconfig.bashls.setup({})

-- Setup pylsp
lspconfig.pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = {"E501"},
                }
            }
        }
    }
})

-- Setup phpactor
lspconfig.phpactor.setup({})

-- Setup html
lspconfig.html.setup({})

-- Setup texlab
lspconfig.texlab.setup({})
