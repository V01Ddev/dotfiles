------------------------------
-- BASIC SETTINGS
------------------------------
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = false

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.opt.spelllang = "en_us"

------------------------------
-- KEYMAPS
------------------------------
local map = vim.keymap.set

map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map({ "n", "v" }, "<leader>df", vim.lsp.buf.code_action, { desc = "LSP code action" })

-- Clipboard mappings
map("n", "<Leader>p", '"+p')
map("n", "<Leader>P", '"+P')
map("v", "<Leader>p", '"+p')
map("v", "<Leader>P", '"+P')
map("n", "<Leader>Y", '"+Y')
map("n", "<Leader>y", '"+y')
map("v", "<Leader>Y", '"+Y')
map("v", "<Leader>y", '"+y')

-- LaTeX keybindings
map("n", "<Leader>lf", "yyplceend<Esc>")
map("n", "<Leader>lb", "a\\textbf{}<Esc>i")
map("n", "<Leader>es", "a\\(\\)<Esc>h")
map("n", "<Leader>el", "a\\[\\]<Esc>hi<Enter><Enter><Esc>k")

------------------------------
-- PLUGINS (lazy.nvim)
------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "tmsvg/pear-tree",

    { "rose-pine/neovim", name = "rose-pine" },

    {
        "lervag/vimtex",
        config = function()
            vim.g.vimtex_quickfix_open_on_warning = 0
            vim.g.vimtex_syntax_enabled = 0
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            map("n", "<leader>ff", builtin.find_files)
            map("n", "<leader>fg", builtin.live_grep)
            map("n", "<leader>fb", builtin.buffers)
            map("n", "<leader>fh", builtin.help_tags)
        end,
    },

    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        opts = {},
    },

    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
})

------------------------------
-- THEME
------------------------------
vim.cmd("colorscheme rose-pine")

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local style = { underline = true }
        vim.api.nvim_set_hl(0, "SpellBad", style)
        vim.api.nvim_set_hl(0, "SpellCap", style)
        vim.api.nvim_set_hl(0, "SpellRare", style)
        vim.api.nvim_set_hl(0, "SpellLocal", style)
    end,
})
vim.cmd("doautocmd ColorScheme")

------------------------------
-- LSP + CMP
------------------------------
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "pylsp", "clangd", "bashls", "gopls", "phpactor", "html", "texlab", "svelte" },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
do
    local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
    end
end

local pylsp_settings = {
    pylsp = {
        plugins = {
            pycodestyle = { enabled = true, ignore = { "E501" }, maxLineLength = 120 },
            mccabe = { enabled = false },
            pyflakes = { enabled = false },
        },
    },
}

local servers = { "pylsp", "gopls", "clangd", "bashls", "phpactor", "html", "texlab", "svelte" }

if vim.fn.has("nvim-0.11") == 1 then
    vim.lsp.config("*", { capabilities = capabilities })
    vim.lsp.config.pylsp = { settings = pylsp_settings }
    vim.lsp.enable(servers)
else
    local lspconfig = require("lspconfig")
    for _, server in ipairs(servers) do
        local cfg = { capabilities = capabilities }
        if server == "pylsp" then cfg.settings = pylsp_settings end
        lspconfig[server].setup(cfg)
    end
end

local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-o>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, { { name = "buffer" }, { name = "path" } }),
})
