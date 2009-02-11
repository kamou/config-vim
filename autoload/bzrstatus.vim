
function! bzrstatus#BzrStatusCleanState()

  if g:BzrStatus_diffbuf
    call setbufvar(g:BzrStatus_diffbuf, '&diff', 0)
    let g:BzrStatus_diffbuf = 0
  endif

  if g:BzrStatus_tmpbuf
    exe 'silent bd '.g:BzrStatus_tmpbuf
    let g:BzrStatus_tmpbuf = 0
  endif

  exe ':sign unplace 42 buffer='.bufnr('')

endfunction

function! bzrstatus#BzrStatusDiffOpen()

  let l = getline('.')
  let m = matchlist(l, g:BzrStatus_matchline)

  if [] == m
    return
  endif

  let f = m[2]

  call bzrstatus#BzrStatusCleanState()

  exe ':sign place 42 line='.line('.').' name=BzrStatusSelection buffer='.bufnr('')

  if 1 == winnr()
    new
    wincmd j
  endif

  if l[1] == 'M'
    wincmd k
    exe 'edit '.f
    let g:BzrStatus_diffbuf = bufnr('')
    let ft = &ft
    diffthis
    rightb vertical new
    let g:BzrStatus_tmpbuf = bufnr('')
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
    let g:BzrStatus_tmpbuf = bufnr('')
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

function! bzrstatus#BzrStatusQuit()

  call bzrstatus#BzrStatusCleanState()

  bwipeout

endfunction

function! bzrstatus#BzrStatusUpdate()

  call bzrstatus#BzrStatusCleanState()

  setlocal modifiable
  exe 'normal ggdG'
  call append(0, g:BzrStatus_bzrcmd)
  redraw
  exe 'silent read !'.g:BzrStatus_bzrcmd
  call search(g:BzrStatus_nextline)
  setlocal nomodifiable

endfunction

function! bzrstatus#BzrStatus()

  silent botright split new
  setlocal buftype=nofile
  file BzrStatus

  if has("syntax") && exists("g:syntax_on")
    syn match BzrStatusAdded    /^[-+R ]N[* ]/
    syn match BzrStatusRemoved  /^[-+R ]D[* ]/
    syn match BzrStatusModified /^[-+R ]M[* ]/
    hi def link BzrStatusAdded DiffAdd
    hi def link BzrStatusRemoved DiffDelete
    hi def link BzrStatusModified DiffChange
    sign define BzrStatusSelection text=>> texthl=Search linehl=Search
  end

  call bzrstatus#BzrStatusUpdate()

  nnoremap <silent> <buffer> <2-Leftmouse> :call bzrstatus#BzrStatusDiffOpen()<CR>
  nnoremap <silent> <buffer> <CR> :call bzrstatus#BzrStatusDiffOpen()<CR>
  nnoremap <silent> <buffer> q :call bzrstatus#BzrStatusQuit()<CR>
  nnoremap <silent> <buffer> u :call bzrstatus#BzrStatusUpdate()<CR>

endfunction

