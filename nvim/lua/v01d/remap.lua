vim.cmd([[
" Latex keybindings
nnoremap <Leader>lf yyplceend<Esc>
nnoremap <Leader>lb a\textbf{}<Esc>i
nnoremap <Leader>es a\(\)<Esc>h
nnoremap <Leader>el a\[\]<Esc>hi<Enter><Enter><Esc>k

nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P

nnoremap <Leader>Y "+Y
nnoremap <Leader>y "+y
vnoremap <Leader>Y "+Y
vnoremap <Leader>y "+y
]])
