
" Make backspace backward delete a char even in normal mode.
map <BS> X

" Use ';' instead of ':'
nnoremap ; :

" Use Esc as escape key in neovim's terminal mode
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif

" For iterating on errors.
nmap <silent> <M-k> :cp<CR>
nmap <silent> <M-j> :cn<CR>

" Quick navigation to the current buffer directory.
nmap <silent> ,d :e %:h<CR>

" Backward delete word and delete word in insert and command mode.
cmap <M-BS> <C-w>
imap <M-BS> <C-w>
nmap <M-BS> db
cmap <M-Del> <C-Right><C-BS>
imap <M-Del> <C-o>de
nmap <M-Del> de

map <silent> <F6> :set hlsearch!<CR>

" Plugin related mappings {{{

    " Cscope:
    nmap <unique> <silent> <Leader>tg <C-]>
    nmap <unique> <silent> <Leader>ts :exe 'cscope find s <cword>'<CR>
    nmap <unique> <silent> <Leader>td :exe 'cscope find d <cword>'<CR>
    nmap <unique> <silent> <Leader>tc :exe 'cscope find c <cword>'<CR>
    nmap <unique> <silent> <Leader>ta :exe 'cscope find t <cword>'<CR>
    nmap <unique> <silent> <Leader>tf :exe 'cscope find f <cfile>'<CR>
    nmap <unique> <silent> <Leader>ti :exe 'cscope find i %:t'<CR>
    nmap <unique> <silent> <Leader>tu :call CscopeUpdate()<CR>
    
    " Ctags:
    let g:ctags_flags = '--c-kinds=+lcdefgmnpstuvx --fields=+S'
    nmap <unique> <Leader>tU :call CtagsUpdate()<CR>

    " LineDiff:
    vmap <unique> <silent> <Leader>dd :Linediff<CR>

" }}}
