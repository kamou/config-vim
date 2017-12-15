
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


" Quick navigation to the current buffer directory.
nnoremap <silent> ,d :e %:h<CR>

" Backward delete word and delete word in insert and command mode.
cnoremap <M-BS> <C-w>
inoremap <M-BS> <C-w>
nnoremap <M-BS> db
cnoremap <M-Del> <C-Right><C-BS>
inoremap <M-Del> <C-o>de
nnoremap <M-Del> de

" open Explorer on split
nnoremap <C-w>v :Sexplore!<CR>
nnoremap <C-w>s :Sexplore<CR>

" Toggle search highlighting
map <silent> <F6> :set hlsearch!<CR>

" Plugin related mappings {{{

    " Cscope:
    nmap <silent> <Leader>tg <C-]>
    nmap <silent> <Leader>ts :exe 'lcscope find s <cword>'<CR>
    nmap <silent> <Leader>td :exe 'lcscope find d <cword>'<CR>
    nmap <silent> <Leader>tc :exe 'lcscope find c <cword>'<CR>
    nmap <silent> <Leader>ta :exe 'lcscope find t <cword>'<CR>
    nmap <silent> <Leader>tf :exe 'lcscope find f <cfile>'<CR>
    nmap <silent> <Leader>ti :exe 'lcscope find i %:t'<CR>
    nmap <silent> <Leader>tu :call CscopeUpdate()<CR>
    
    " Ctags:
    if executable('ctags')
        let g:ctags_flags = '--c-kinds=+lcdefgmnpstuvx --fields=+S'
        nmap <Leader>tU :call CtagsUpdate()<CR>
    endif

    " LineDiff:
    vmap <silent> <Leader>dd :Linediff<CR>

    " Fugitive:
    nnoremap <silent> <Leader>gd :Gdiff<cr>
    nnoremap <silent> <Leader>gs :Gstatus<cr>
    nnoremap <silent> <Leader>gc :Gcommit<cr>
    nnoremap <silent> <Leader>gl :Glog<cr>
    nnoremap <silent> <Leader>ge :Gedit<cr>
    nnoremap <silent> <Leader>gb :Gblame<cr>
    " TODO: prompt for branch names if current branch is not master
    nnoremap <silent> <Leader>gpl :Gpull origin master:master<cr>
    nnoremap <silent> <Leader>gps :Gpush origin master:master<cr>

    " TmuxNavigator:
    nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>
    nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>
    nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>
    nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>
    nnoremap <silent> <C-w>w :TmuxNavigatePrevious<cr>

    " TagBar:
    nnoremap <silent> <Leader>tb :TagbarOpenAutoClose<cr>

    " IndentWise:
    nmap <Leader>k <Plug>(IndentWisePreviousEqualIndentKamou)
    nmap <Leader>j <Plug>(IndentWiseNextEqualIndentKamou)
    nmap <Leader>l <Plug>(IndentWiseNextGreaterIndent)
    nmap <Leader>h <Plug>(IndentWisePreviousGreaterIndent)

    " CtrlSpace:
    " dunno why I need this for ubuntu...
    nmap <C-Space> :CtrlSpace<cr>

" }}}
