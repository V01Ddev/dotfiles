require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "ltex",
    }
})

require("lspconfig").clangd.setup{}
