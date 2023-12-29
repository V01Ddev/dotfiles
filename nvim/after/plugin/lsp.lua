require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pylsp",
        "ltex",
        "arduino_language_server"
    }
})

require("lspconfig").clangd.setup{}
