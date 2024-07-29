require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = {
        "python", 
        "c",
        "cpp",
        "bash",
        "html",
        "css"},

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = false,

    highlight = {
        -- `false` will disable the whole extension
        enable = true,
        additional_vim_regex_highlighting = true,
    }, 

    -- enable indentation
    indent = { 
        enable = true,
        -- disable = { "php" },
    },

    -- making PHP use HTML
    -- vim.treesitter.language.register('html', 'php')
}
