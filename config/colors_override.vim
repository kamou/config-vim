

hi ColorColumn cterm=inverse
call matchadd('ColorColumn', '\%81v', 100)

" Colorscheme.
hi DiffAdd    ctermbg=235  ctermfg=108  guibg=#262626 guifg=#87af87 cterm=reverse gui=reverse
hi DiffChange ctermbg=235  ctermfg=103  guibg=#262626 guifg=#8787af cterm=reverse gui=reverse
hi DiffDelete ctermbg=235  ctermfg=131  guibg=#262626 guifg=#af5f5f cterm=reverse gui=reverse
hi DiffText   ctermbg=235  ctermfg=208  guibg=#262626 guifg=#ff8700 cterm=reverse gui=reverse


highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
