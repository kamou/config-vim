
" Support for automatically using DirDiff when calling 'vim -d dir1 dir2'. {{{

function! VimDirDiff()

  let dir1 = fnameescape(argv(0))
  let dir2 = fnameescape(argv(1))
  silent! exe 'bd '.dir1
  silent! exe 'bd '.dir2
  silent exe 'DirDiff '.dir1.' '.dir2
  windo filetype detect

endfunction

if &diff && 2 == argc() && isdirectory(argv(0)) && isdirectory(argv(1))
  autocmd VimEnter * call VimDirDiff()
endif

" }}}
"
if has('cscope')

  function! CscopeUpdate()

    exe 'silent! cs kill cscope.out'

    let cmd = '!cscope -q -b -f cscope.out'
    let files = 'cscope.files'

    if filereadable(files)
      let cmd .= ' -i '.files
    else
      let cmd .= ' -R -s .'
    endif

    exe cmd
    exe 'silent cs add cscope.out'

  endfunction
endif

function! CtagsUpdate()

  let cmd = '!ctags '.g:ctags_flags.' -o tags -R '
  let files = 'tags.files'

  if filereadable(files)
    let cmd .= '-L '.files
  else
    let cmd .= '.'
  endif

  exe cmd

endfunction

" vim: ft=vim sw=2 foldmethod=marker foldlevel=0
