 " Unicode by default
scriptencoding utf-8

" Fix runtimepath. {{{

" Make sure $USERVIM is present first in runtimepath, and $USERVIM/after last.
" Also remove dupplicate and directories that don't exist.

let uvim = simplify($USERVIM)
let uvim_after = simplify($USERVIM.'/after')

let rl = split(&runtimepath, ',')
let newrl = []

for path in rl
  let path = simplify(path)
  if isdirectory(path) && -1 == index(newrl, path)
    call add(newrl, path)
  endif
endfor

if 0 != len(newrl)
  if uvim != newrl[0]
    call insert(newrl, uvim, 0)
  endif
  if uvim_after != newrl[-1]
    call add(newrl, uvim_after)
  endif
endif

let &runtimepath = join(newrl, ',')

" }}}

" Load user config (username, email, ...).
let user = $USERVIM.'/user'
if filereadable(user)
  execute 'source '.user
endif

