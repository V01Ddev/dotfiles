require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "phpactor",
        "eslint",
        "ltex",
    }
})

require("lspconfig").clangd.setup{}
