
" Make backspace backward delete a char even in normal mode.
map <BS> X

" Use ';' instead of ':'
nnoremap ; :
vnoremap ; :

" Use jk to exit insert mode
inoremap jk <esc>
" disable <esc> key in insert mode
inoremap <esc> <nop>

" Use Esc as escape key in neovim's terminal mode
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif

" For iterating on errors.
nnoremap <silent> <M-k> :cp<CR>
nnoremap <silent> <M-j> :cn<CR>

" Quick navigation to the current buffer directory.
nnoremap <silent> ,d :e %:h<CR>

" Backward delete word and delete word in insert and command mode.
cnoremap <M-BS> <C-w>
inoremap <M-BS> <C-w>
nnoremap <M-BS> db
cnoremap <M-Del> <C-Right><C-BS>
inoremap <M-Del> <C-o>de
nnoremap <M-Del> de

" Toggle search highlighting
map <silent> <F6> :set hlsearch!<CR>

" Plugin related mappings {{{

    " Cscope:
    nmap <silent> <Leader>tg <C-]>
    nmap <silent> <Leader>ts :exe 'cscope find s <cword>'<CR>
    nmap <silent> <Leader>td :exe 'cscope find d <cword>'<CR>
    nmap <silent> <Leader>tc :exe 'cscope find c <cword>'<CR>
    nmap <silent> <Leader>ta :exe 'cscope find t <cword>'<CR>
    nmap <silent> <Leader>tf :exe 'cscope find f <cfile>'<CR>
    nmap <silent> <Leader>ti :exe 'cscope find i %:t'<CR>
    nmap <silent> <Leader>tu :call CscopeUpdate()<CR>
    
    " Ctags:
    let g:ctags_flags = '--c-kinds=+lcdefgmnpstuvx --fields=+S'
    nmap <Leader>tU :call CtagsUpdate()<CR>

    " LineDiff:
    vmap <silent> <Leader>dd :Linediff<CR>

    " Fugitive:
    nnoremap <silent> <Leader>gd :Gdiff<cr>
    nnoremap <silent> <Leader>gs :Gstatus<cr>
    nnoremap <silent> <Leader>gc :Gcommit<cr>
    nnoremap <silent> <Leader>gpl :Gpull<cr>
    nnoremap <silent> <Leader>gps :Gpush<cr>

    " TmuxNavigator:
    nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>
    nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>
    nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>
    nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>
    nnoremap <silent> <C-w>w :TmuxNavigatePrevious<cr>

    " TagBar:
    nnoremap <silent> <Leader>tb :TagbarOpenAutoClose<cr>

" }}}
