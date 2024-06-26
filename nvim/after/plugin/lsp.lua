require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "clangd",
        "ltex",
        "phpactor"
    }
})

require("lspconfig").clangd.setup{}
