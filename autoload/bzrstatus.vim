
function! bzrstatus#clean_state()

  if t:bzrstatus_diffbuf
    call setbufvar(t:bzrstatus_diffbuf, '&diff', 0)
    let t:bzrstatus_diffbuf = 0
  endif

  if t:bzrstatus_tmpbuf
    exe 'silent bd '.t:bzrstatus_tmpbuf
    let t:bzrstatus_tmpbuf = 0
  endif

  exe ':sign unplace 42 buffer='.bufnr('')

endfunction

function! bzrstatus#diff_open()

  let l = getline('.')
  let m = matchlist(l, t:bzrstatus_matchline)

  if [] == m
    return
  endif

  let f = t:bzrstatus_tree.'/'.m[2]

  call bzrstatus#clean_state()

  exe ':sign place 42 line='.line('.').' name=bzrstatusSelection buffer='.bufnr('')

  if 1 == winnr()
    new
    wincmd j
  endif

  if l[1] == 'M'
    wincmd k
    exe 'edit '.fnameescape(f)
    let t:bzrstatus_diffbuf = bufnr('')
    let ft = &ft
    diffthis
    rightb vertical new
    let t:bzrstatus_tmpbuf = bufnr('')
    redraw
    exe 'silent read !bzr cat '.shellescape(f)
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
    let t:bzrstatus_tmpbuf = bufnr('')
    redraw
    exe 'silent read !bzr cat '.shellescape(f)
    exe 'normal 1Gdd'
    setlocal buftype=nofile
    wincmd j
    return
  endif

  echo l[0]

  if l[1] == 'N' || l[0] == '?'
    wincmd k
    exe 'edit '.fnameescape(f)
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

  setlocal modifiable fenc=utf-8
  exe 'normal ggdG'
  let cmd = 'bzr status -S --no-pending --versioned '.shellescape(t:bzrstatus_path)
  call append(0, cmd)
  redraw
  exe 'silent read !'.cmd
  call search(t:bzrstatus_nextline)
  setlocal nomodifiable

endfunction

function! bzrstatus#start(...)

  if a:0
    let path = a:1
  else
    let path = '.'
  end

  let t:bzrstatus_path = fnamemodify(path, ':p')
  let t:bzrstatus_tree = system('bzr root '.shellescape(t:bzrstatus_path))[0:-2]
  let t:bzrstatus_nextline = '^[-+R ][NDM][* ]\s\+\(.*\)$'
  let t:bzrstatus_matchline = '^\([-+R ][NDM][* ]\|?  \|  \*\)\s\+\(.*\)$'
  let t:bzrstatus_tmpbuf = 0
  let t:bzrstatus_diffbuf = 0

  silent botright split new
  setlocal buftype=nofile ft=bzrstatus
  exe 'file '.fnameescape(t:bzrstatus_tree)

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

