require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "phpactor",
        "eslint-lsp",
        "ltex",
    }
})

require("lspconfig").clangd.setup{}
