" Tabs
set number relativenumber
set tabstop=4
set shiftwidth=4

" Indent
set smartindent
set smarttab

" Everything else
syntax on
set ttyfast
set clipboard+=unnamedplus

" Custom macros that I always use
let @f = "yyplvecend\<Esc>"
let @b = "a\\textbf{\<Esc>l"

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Plugins
Plug 'tmsvg/pear-tree'
Plug 'vim-airline/vim-airline'
Plug 'lervag/vimtex'

" VimTeX config 
let g:vimtex_compiler_method = 'tectonic'
let g:vimtex_compiler_tectonic = {
			\ 'out_dir' : '',
			\ 'hooks' : [],
			\ 'options' : [
			\   '',
			\ ],
			\}

let g:vimtex_quickfix_enabled = 0
call plug#end()
