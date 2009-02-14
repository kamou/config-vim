
let s:bzrstatus_nextline = '^[-+R ][NDM][* ]\s'
let s:bzrstatus_matchline = '^\([-+R ][NDM][* ]\|?  \|  \*\)\s\+\(.*\)$'

function! bzrstatus#clean_state()

  if exists('t:bzrstatus_diffbuf')
    call setbufvar(t:bzrstatus_diffbuf, '&diff', 0)
    unlet t:bzrstatus_diffbuf
  endif

  if exists('t:bzrstatus_tmpbuf')
    exe 'silent bd '.t:bzrstatus_tmpbuf
    unlet t:bzrstatus_tmpbuf
  endif

  if has('signs')
    exe ':sign unplace 2 buffer='.t:bzrstatus_buffer
  end

endfunction

function! bzrstatus#diff_open()

  let l = getline('.')
  let m = matchlist(l, s:bzrstatus_matchline)

  if [] == m
    return
  endif

  let renamed = (l[0] == 'R')
  let unknown = (l[0] == '?')
  let modified = (l[1] == 'M')
  let deleted = (l[1] == 'D')
  let added = (l[1] == 'N')

  let old_entry = m[2]

  if renamed

    let m = matchlist(old_entry, '^\(.*\) => \(.*$\)')

    if [] == m
      echoerr 'error parsing line: '.l
      return
    endif

    let old_entry = m[1]
    let new_entry = m[2]

  else

    let new_entry = old_entry

  endif

  let old_entry_fullpath = t:bzrstatus_tree.'/'.old_entry
  let new_entry_fullpath = t:bzrstatus_tree.'/'.new_entry

  call bzrstatus#clean_state()

  if has('signs')
    exe ':sign place 2 line='.line('.').' name=bzrstatus_sign_selection buffer='.t:bzrstatus_buffer
  end

  if 1 == winnr('$')
    new
  else
    wincmd k
  endif

  if modified || added || unknown
    " Open current tree version.
    exe 'edit '.fnameescape(new_entry_fullpath)
  endif

  if modified
    " Prepare for diff...
    let t:bzrstatus_diffbuf = bufnr('')
    let ft = &ft
    diffthis
    rightb vertical new
  elseif deleted
    " ...or original version display.
    enew
  endif

  if modified || deleted
    " Get original version from Bazaar.
    let t:bzrstatus_tmpbuf = bufnr('')
    exe 'file [BZR] '.fnameescape(old_entry)
    redraw
    exe 'silent read !'.g:bzrstatus_bzr.' cat '.shellescape(old_entry_fullpath)
    exe 'normal 1Gdd'
    setlocal buftype=nofile
  end

  if modified
    " Set filetype from original for correct syntax highlighting...
    let &ft = ft
    diffthis
  elseif deleted
    " ...or try to detect it
    filetype detect
  endif

  exe bufwinnr(t:bzrstatus_buffer).' wincmd w'

endfunction

function! bzrstatus#quit()

  call bzrstatus#clean_state()

  bwipeout

endfunction

function! bzrstatus#update()

  call bzrstatus#clean_state()

  setlocal modifiable fenc=utf-8
  exe 'normal ggdG'
  let cmd = g:bzrstatus_bzr.' status -S '.shellescape(t:bzrstatus_path)
  call append(0, cmd)
  redraw
  exe 'silent read !'.cmd
  exe 'normal gg'
  call search(s:bzrstatus_nextline, 'eW')
  setlocal nomodifiable

endfunction

function! bzrstatus#start(...)

  if a:0
    let path = a:1
  else
    let path = '.'
  end

  let t:bzrstatus_path = fnamemodify(path, ':p')
  let t:bzrstatus_tree = system(g:bzrstatus_bzr.' root '.shellescape(t:bzrstatus_path))[0:-2]

  silent botright split new
  setlocal buftype=nofile ft=bzrstatus
  exe 'file '.fnameescape(t:bzrstatus_tree)

  let t:bzrstatus_buffer = bufnr('')

  if has('signs')
    sign define bzrstatus_sign_selection text=>> texthl=Search linehl=Search
    sign define bzrstatus_sign_start
    exe ':sign place 1 line=1 name=bzrstatus_sign_start buffer='.t:bzrstatus_buffer
  endif

  call bzrstatus#update()

  nnoremap <silent> <buffer> <2-Leftmouse> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> <CR> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> q :call bzrstatus#quit()<CR>
  nnoremap <silent> <buffer> u :call bzrstatus#update()<CR>

endfunction

