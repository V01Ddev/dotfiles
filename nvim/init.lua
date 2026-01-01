------------------------------
-- BASIC SETTINGS
------------------------------
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- vim.opt.spell = true
vim.opt.spelllang = 'en_us'


------------------------------
-- KEYMAPS
------------------------------
local map = vim.keymap.set

-- LaTeX keybindings
map('n', '<Leader>lf', 'yyplceend<Esc>')
map('n', '<Leader>lb', 'a\\textbf{}<Esc>i')
map('n', '<Leader>es', 'a\\(\\)<Esc>h')
map('n', '<Leader>el', 'a\\[\\]<Esc>hi<Enter><Enter><Esc>k')

-- Clipboard mappings
map('n', '<Leader>p', '"+p')
map('n', '<Leader>P', '"+P')
map('v', '<Leader>p', '"+p')
map('v', '<Leader>P', '"+P')

map('n', '<Leader>Y', '"+Y')
map('n', '<Leader>y', '"+y')
map('v', '<Leader>Y', '"+Y')
map('v', '<Leader>y', '"+y')

-- Diagnostics
map('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
map('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Code action
map({ 'n', 'v' }, '<leader>df', vim.lsp.buf.code_action, { desc = 'LSP code action' })


------------------------------
-- PLUGINS
------------------------------
-- Bootstrap lazy.nvim
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
    -- Auto-pair plugin.
    'tmsvg/pear-tree',

    -- LaTeX
    {
        'lervag/vimtex',
        config = function()
            vim.g.vimtex_quickfix_open_on_warning = 0
            vim.g.vimtex_syntax_enabled = 0
        end

    },

    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            map('n', '<leader>ff', builtin.find_files)
            map('n', '<leader>fg', builtin.live_grep)
            map('n', '<leader>fb', builtin.buffers)
            map('n', '<leader>fh', builtin.help_tags)
        end
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = { "python", "c", "bash", "html", "css", "javascript" },
                auto_install = false,
                highlight = { enable = true, additional_vim_regex_highlighting = true },
                indent = { enable = true },
            }
        end
    },

    -- LSP
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    'neovim/nvim-lspconfig',

    -- Completion
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',

    -- Snippets
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',

    -- Theme
    'rose-pine/neovim'
})


------------------------------
-- THEME
------------------------------
vim.cmd('colorscheme rose-pine')

-- ensure spell underlining is working under tmux
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local style = { underline = true }
    vim.api.nvim_set_hl(0, "SpellBad",   style)
    vim.api.nvim_set_hl(0, "SpellCap",   style)
    vim.api.nvim_set_hl(0, "SpellRare",  style)
    vim.api.nvim_set_hl(0, "SpellLocal", style)
  end,
})

vim.cmd("doautocmd ColorScheme")


------------------------------
-- LSP CONFIG (Neovim ≥ 0.11)
------------------------------
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
        "pylsp",
        "clangd",
        "bashls",
        "gopls",
        "phpactor",
        "html",
        "texlab",
    },
})

-- Default config for all servers
vim.lsp.config("*", {
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})

-- Custom config for pylsp
vim.lsp.config.pylsp = {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true,
          ignore = { "E501" },
          maxLineLength = 120,
        },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
      },
    },
  },
}

-- Enable all installed servers
vim.lsp.enable({ 
    "pylsp",
    "gopls",
    "clangd",
    "bashls",
    "phpactor",
    "html",
    "texlab",
    "svelte"
})


------------------------------
-- COMPLETION CONFIG
------------------------------
local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-o>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"]  = cmp.mapping.confirm({ select = true }),
  }),
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
})
