
" Profiling. {{{

" profile start vim.prof | profile! file *

" }}}
if has('nvim')
  let $VIMFOLDER='nvim'
else
  let $VIMFOLDER='vim'
endif

if strlen($XDG_CONFIG_HOME)
  let $USERVIM=$XDG_CONFIG_HOME.'/'.$VIMFOLDER
else
  let $USERVIM=$HOME.'/.config/'.$VIMFOLDER
endif

if has('win32') && !strlen($CYGPATH)
  let $CYGPATH='c:/cygwin'
endif

" Load user vimrc from $USERVIM/rc.
let user_rc=$USERVIM."/rc"
if filereadable(user_rc)
  execute "source " . user_rc
endif

" Load user gvimrc from $USERVIM/grc.
if has("gui_running")
  let user_grc=$USERVIM."/grc"
  if filereadable(user_grc)
    execute "source " . user_grc
  endif
endif

" vim: ft=vim sw=2
