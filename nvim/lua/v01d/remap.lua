--  Anything starting with l is meant to be used with latex
vim.cmd([[
nnoremap <Leader>lf yyplceend<Esc>
nnoremap <Leader>lb a\textbf{<Esc>l
nnoremap <Leader>les a\(\)<Esc>h
nnoremap <Leader>lel a\[\]<Esc>hi<Enter><Enter><Esc>k

nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P

nnoremap <Leader>Y "+Y
nnoremap <Leader>y "+y
vnoremap <Leader>Y "+Y
vnoremap <Leader>y "+y
]])
