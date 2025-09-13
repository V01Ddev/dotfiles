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


------------------------------
-- PACKER PLUGINS
------------------------------
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    -- Packer manages itself
    use 'wbthomason/packer.nvim'

    -- Auto-pair plugin.
    use 'tmsvg/pear-tree'

    -- LaTeX & Utilities
    use {
        'lervag/vimtex',
        config = function()
            vim.g.vimtex_quickfix_open_on_warning = 0
            vim.g.vimtex_syntax_enabled = 0
        end

    }

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            map('n', '<leader>ff', builtin.find_files)
            map('n', '<leader>fg', builtin.live_grep)
            map('n', '<leader>fb', builtin.buffers)
            map('n', '<leader>fh', builtin.help_tags)
        end
    }

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
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
    }

    -- LSP
    use {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig'
    }

    -- Completion
    use {
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path'
    }

    -- Snippets
    use {
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip'
    }

    -- Theme
    use 'rose-pine/neovim'
end)


------------------------------
-- THEME
------------------------------
vim.cmd('colorscheme rose-pine')


------------------------------
-- LSP CONFIG
------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
    automatic_enable = false,
    ensure_installed = { "pylsp", "clangd", "bashls", "phpactor", "html", "texlab" }
})

local lspconfig = require("lspconfig")

-- Servers
lspconfig.clangd.setup({})
lspconfig.bashls.setup({})
lspconfig.pylsp.setup({
    settings = {
        pylsp = { plugins = { pycodestyle = { ignore = {"E501"} } } }
    }
})
lspconfig.phpactor.setup({})
lspconfig.html.setup({})
lspconfig.texlab.setup({})


------------------------------
-- COMPLETION CONFIG
------------------------------
local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-o>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
            { name = 'buffer' },
        }),
})
