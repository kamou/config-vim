
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

  if strlen($CSCOPE_DB)
    let g:cscopedb=$CSCOPE_DB
  else
    let g:cscopedb='cscope.out'
  endif

  set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-
  set cspc=3

  " Check for either stock cscope executable or for the multi-lingual cscope
  " version (which is the one available in Cygwin).
  if !executable(&cscopeprg)
    if executable('cscope')
      set cscopeprg=cscope
    elseif executable('mlcscope')
      set cscopeprg=mlcscope
    endif
  endif

  " Automatically add database if it exists.
  if filereadable(g:cscopedb)
    exe 'silent cs add '.g:cscopedb
  endif

  " Uses cstag (and so cscope if available...).
  set cst
  " Search the tags database before the cscope database...
  set csto=1

  function! CscopeUpdate()

    exe 'silent! cs kill '.fnamemodify(g:cscopedb, ':p')

    let cmd = '!'.&cscopeprg.' -q -b -f '.g:cscopedb
    let files = 'cscope.files'

    if filereadable(files)
      let cmd .= ' -i '.files
    else
      let cmd .= ' -R -s .'
    endif

    exe cmd
    exe 'silent cs add '.g:cscopedb

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
