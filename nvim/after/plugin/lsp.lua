require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "ruff",
        "clangd",
        "phpactor",
        "html",
        "texlab",
    }
})

require("lspconfig").clangd.setup{}
