
function! bzrstatus#clean_state()

  if g:bzrstatus_diffbuf
    call setbufvar(g:bzrstatus_diffbuf, '&diff', 0)
    let g:bzrstatus_diffbuf = 0
  endif

  if g:bzrstatus_tmpbuf
    exe 'silent bd '.g:bzrstatus_tmpbuf
    let g:bzrstatus_tmpbuf = 0
  endif

  exe ':sign unplace 42 buffer='.bufnr('')

endfunction

function! bzrstatus#diff_open()

  let l = getline('.')
  let m = matchlist(l, g:bzrstatus_matchline)

  if [] == m
    return
  endif

  let f = m[2]

  call bzrstatus#clean_state()

  exe ':sign place 42 line='.line('.').' name=bzrstatusSelection buffer='.bufnr('')

  if 1 == winnr()
    new
    wincmd j
  endif

  if l[1] == 'M'
    wincmd k
    exe 'edit '.f
    let g:bzrstatus_diffbuf = bufnr('')
    let ft = &ft
    diffthis
    rightb vertical new
    let g:bzrstatus_tmpbuf = bufnr('')
    redraw
    exe 'silent read !bzr cat '.f
    exe 'normal 1Gdd'
    setlocal buftype=nofile
    let &ft = ft
    diffthis
    wincmd j
    return
  endif

  if l[1] == 'D'
    wincmd k
    enew
    let g:bzrstatus_tmpbuf = bufnr('')
    redraw
    exe 'silent read !bzr cat '.f
    exe 'normal 1Gdd'
    setlocal buftype=nofile
    wincmd j
    return
  endif

  echo l[0]

  if l[1] == 'N' || l[0] == '?'
    wincmd k
    exe 'edit '.f
    wincmd j
    return
  endif

endfunction

function! bzrstatus#quit()

  call bzrstatus#clean_state()

  bwipeout

endfunction

function! bzrstatus#update()

  call bzrstatus#clean_state()

  setlocal modifiable
  exe 'normal ggdG'
  call append(0, g:bzrstatus_bzrcmd)
  redraw
  exe 'silent read !'.g:bzrstatus_bzrcmd
  call search(g:bzrstatus_nextline)
  setlocal nomodifiable

endfunction

function! bzrstatus#start()

  silent botright split new
  setlocal buftype=nofile
  file bzrstatus

  if has("syntax") && exists("g:syntax_on")
    syn match bzrstatusAdded    /^[-+R ]N[* ]/
    syn match bzrstatusRemoved  /^[-+R ]D[* ]/
    syn match bzrstatusModified /^[-+R ]M[* ]/
    hi def link bzrstatusAdded DiffAdd
    hi def link bzrstatusRemoved DiffDelete
    hi def link bzrstatusModified DiffChange
    sign define bzrstatusSelection text=>> texthl=Search linehl=Search
  end

  call bzrstatus#update()

  nnoremap <silent> <buffer> <2-Leftmouse> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> <CR> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> q :call bzrstatus#quit()<CR>
  nnoremap <silent> <buffer> u :call bzrstatus#update()<CR>

endfunction

