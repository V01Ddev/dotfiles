require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "bashls",
        "phpactor",
        "html",
        "texlab",
    }
})

-- Setup lspconfig
local lspconfig = require("lspconfig")

-- Setup clangd
lspconfig.clangd.setup({})

-- Setup bashls
lspconfig.bashls.setup({})

-- Setup pylsp
lspconfig.pylsp.setup({})

-- Setup phpactor
lspconfig.phpactor.setup({})

-- Setup html
lspconfig.html.setup({})

-- Setup texlab
lspconfig.texlab.setup({})
