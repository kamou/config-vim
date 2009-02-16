
let s:bzrstatus_nextline = '^[-+R ][NDM][* ]\s'
let s:bzrstatus_matchline = '^\([-+R ][NDM][* ]\|[R?]  \|  \*\)\s\+\(.*\)$'

function! bzrstatus#tag(ln)

    let t:bzrstatus_tagged[a:ln] = 1

    if has('signs')
      if a:ln == t:bzrstatus_selection
        let sign = 'bzrstatus_sign_selection_tag'
      else
        let sign = 'bzrstatus_sign_tag'
      endif
      exe ':sign place '.a:ln.' line='.a:ln.' name='.sign.' buffer='.t:bzrstatus_buffer
    endif

endfunction

function! bzrstatus#untag(ln)

    call remove(t:bzrstatus_tagged, a:ln)

    if has('signs')
      if a:ln == t:bzrstatus_selection
        exe ':sign place '.a:ln.' line='.a:ln.' name=bzrstatus_sign_selection buffer='.t:bzrstatus_buffer
      else
        exe ':sign unplace '.a:ln.' buffer='.t:bzrstatus_buffer
      endif
    endif

endfunction

function! bzrstatus#clear_tagged()

  if has('signs')
    for ln in keys(t:bzrstatus_tagged)
      call bzrstatus#untag(ln)
    endfor
  endif

  let t:bzrstatus_tagged = {}

endfunction

function! bzrstatus:select(ln)

  if has('signs')
    if has_key(t:bzrstatus_tagged, a:ln)
      let sign = 'bzrstatus_sign_selection_tag'
    else
      let sign = 'bzrstatus_sign_selection'
    endif
    exe ':sign place '.a:ln.' line='.a:ln.' name='.sign.' buffer='.t:bzrstatus_buffer
  end

  let t:bzrstatus_selection = a:ln

endfunction

function! bzrstatus#unselect()

  if has('signs')
    if has_key(t:bzrstatus_tagged, t:bzrstatus_selection)
      exe ':sign place '.t:bzrstatus_selection.' line='.t:bzrstatus_selection.' name=bzrstatus_sign_tag buffer='.t:bzrstatus_buffer
    else
      exe ':sign unplace '.t:bzrstatus_selection.' buffer='.t:bzrstatus_buffer
    endif
  endif

  let t:bzrstatus_selection = 0

endfunction

function! bzrstatus#clean_state(clear_tagged)

  if exists('t:bzrstatus_diffbuf')
    call setbufvar(t:bzrstatus_diffbuf, '&diff', 0)
    set nodiff noscrollbind
    unlet t:bzrstatus_diffbuf
  endif

  if exists('t:bzrstatus_tmpbuf')
    exe 'silent bd '.t:bzrstatus_tmpbuf
    unlet t:bzrstatus_tmpbuf
  endif

  call bzrstatus#unselect()

  if a:clear_tagged
    call bzrstatus#clear_tagged()
  end

endfunction

function! bzrstatus#parse_entry_state(ln)

  if a:ln > t:bzrstatus_msgline
    return []
  endif

  let l = getline(a:ln)
  let m = matchlist(l, s:bzrstatus_matchline)

  if [] == m
    return []
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

  return [renamed, unknown, modified, deleted, added, old_entry, old_entry_fullpath, new_entry, new_entry_fullpath]

endfunction

function! bzrstatus#filter_entries(range, criterion)

  let files = []

  for ln in a:range

    let s = bzrstatus#parse_entry_state(ln)
    if [] == s
      continue
    endif

    let [renamed, unknown, modified, deleted, added, old_entry, old_entry_fullpath, new_entry, new_entry_fullpath] = s
    if !eval(a:criterion)
      continue
    endif

    let files += [new_entry_fullpath]

  endfor

  return files

endfunction

function! bzrstatus#diff_open()

  let ln = line('.')

  let s = bzrstatus#parse_entry_state(ln)
  if [] == s
    return
  endif

  let [renamed, unknown, modified, deleted, added, old_entry, old_entry_fullpath, new_entry, new_entry_fullpath] = s

  call bzrstatus#clean_state(0)

  call bzrstatus:select(ln)

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
    let fenc = &fenc
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
    let ft = ft
    let fenc = fenc
    diffthis
  elseif deleted
    " ...or try to detect it
    filetype detect
  endif

  exe bufwinnr(t:bzrstatus_buffer).' wincmd w'

endfunction

function! bzrstatus#exec_bzr(cmd, files, confirm)

  setlocal modifiable

  if line('$') > t:bzrstatus_msgline
    exe 'silent '.(t:bzrstatus_msgline + 1).',$delete'
  endif

  let cmd = a:cmd

  if [] != a:files
    let files = map(a:files, 'shellescape(v:val)')
    let cmd = cmd.' '.join(files, ' ')
  endif

  if a:confirm && 2 == confirm(cmd, "&Yes\n&No", 2)
    setlocal nomodifiable
    return
  endif

  let cmd = g:bzrstatus_bzr.' '.cmd

  call append(t:bzrstatus_msgline, [cmd, ''])
  redraw

  exe ':'.(t:bzrstatus_msgline + 2)
  let tf = tempname()
  exe '!2>'.tf.' '.cmd
  exe 'read '.tf
  exe 'silent! '.t:bzrstatus_msgline.',$s/\s*\r//g'

  call bzrstatus#update(0)

endfunction

function! bzrstatus#toggle_tag()

  let ln = line('.')

  if has_key(t:bzrstatus_tagged, ln)
    call bzrstatus#untag(ln)
  else
    call bzrstatus#tag(ln)
  endif

endfunction

function! bzrstatus#bzr_op(tagged, firstl, lastl, criterion, cmd, confirm)

  if a:tagged
    let r = keys(t:bzrstatus_tagged)
  else
    let r = range(a:firstl, a:lastl)
  endif

  if [] == r
    return
  endif

  let files = bzrstatus#filter_entries(r, a:criterion)
  if [] == files
    return
  endif

  call bzrstatus#exec_bzr(a:cmd, files, a:confirm)

endfunction

function! bzrstatus#add(tagged) range

  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'unknown', 'add', 1)

endfunction

function! bzrstatus#commit(tagged) range

  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, '!unknown', 'commit', 1)

endfunction

function! bzrstatus#del(tagged) range

  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, '!unknown && !deleted', 'del', 1)

endfunction

function! bzrstatus#revert(tagged) range

  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'modified || deleted || renamed', 'revert', 1)

endfunction

function! bzrstatus#shelve(tagged) range

  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, '!unknown', 'shelve', 1)

endfunction

function! bzrstatus#unshelve()

  call bzrstatus#exec_bzr('unshelve', [], 1)

endfunction

function! bzrstatus#quit()

  call bzrstatus#clean_state(1)

  bwipeout

endfunction

function! bzrstatus#update(all)

  call bzrstatus#clean_state(1)

  let t:bzrstatus_tagged = {}

  setlocal modifiable

  if !a:all && exists('t:bzrstatus_msgline')
    exe 'silent 1,'.(t:bzrstatus_msgline - 1).'delete'
  else
    silent %delete
  endif

  let cmd = g:bzrstatus_bzr.' status -S '.shellescape(t:bzrstatus_path)
  call append(0, cmd)
  redraw

  :2
  exe 'silent read !'.cmd

  let l = line('.')
  call append(l, '')
  let t:bzrstatus_msgline = l + 1

  :2
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
  let t:bzrstatus_selection = 0
  let t:bzrstatus_tagged = {}

  silent botright split new
  setlocal buftype=nofile ft=bzrstatus fenc=utf-8
  exe 'silent! file '.fnameescape(t:bzrstatus_tree)

  let t:bzrstatus_buffer = bufnr('')

  if has('signs')
    sign define bzrstatus_sign_selection text=>> texthl=Search linehl=Search
    sign define bzrstatus_sign_selection_tag text=!> texthl=Search
    sign define bzrstatus_sign_tag text=!
    sign define bzrstatus_sign_start
    exe ':sign place 1 line=1 name=bzrstatus_sign_start buffer='.t:bzrstatus_buffer
  endif

  call bzrstatus#update(1)

  nnoremap <silent> <buffer> <2-Leftmouse> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> <CR> :call bzrstatus#diff_open()<CR>
  nnoremap <silent> <buffer> <Space> :call bzrstatus#toggle_tag()<CR>
  nnoremap <silent> <buffer> q :call bzrstatus#quit()<CR>
  nnoremap <silent> <buffer> u :call bzrstatus#update(1)<CR>

  " Operations on current line entry.
  nnoremap <silent> <buffer> A :call bzrstatus#add(0)<CR>
  nnoremap <silent> <buffer> C :call bzrstatus#commit(0)<CR>
  nnoremap <silent> <buffer> D :call bzrstatus#del(0)<CR>
  nnoremap <silent> <buffer> R :call bzrstatus#revert(0)<CR>
  nnoremap <silent> <buffer> S :call bzrstatus#shelve(0)<CR>
  nnoremap <silent> <buffer> U :call bzrstatus#unshelve()<CR>

  " Operations on visual selection entries.
  vnoremap <silent> <buffer> A :call bzrstatus#add(0)<CR>
  vnoremap <silent> <buffer> C :call bzrstatus#commit(0)<CR>
  vnoremap <silent> <buffer> D :call bzrstatus#del(0)<CR>
  vnoremap <silent> <buffer> R :call bzrstatus#revert(0)<CR>
  vnoremap <silent> <buffer> S :call bzrstatus#shelve(0)<CR>

  " Operation on tagged entries.
  nnoremap <silent> <buffer> ,A :call bzrstatus#add(1)<CR>
  nnoremap <silent> <buffer> ,C :call bzrstatus#commit(1)<CR>
  nnoremap <silent> <buffer> ,D :call bzrstatus#del(1)<CR>
  nnoremap <silent> <buffer> ,R :call bzrstatus#revert(1)<CR>
  nnoremap <silent> <buffer> ,S :call bzrstatus#shelve(1)<CR>

endfunction

