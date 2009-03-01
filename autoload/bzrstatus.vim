
let s:bzrstatus_mappings =
      \ {
      \ 'quit'     : [ 'q', ],
      \ 'update'   : [ 'u', ],
      \ 'diff_open': [ '<2-Leftmouse>', '<CR>' ],
      \ 'exec'     : [ 'e' ],
      \ 'info'     : [ 'i' ],
      \ 'log'      : [ 'l' ],
      \ 'missing'  : [ 'm' ],
      \
      \ 'add'     : [ 'A' ],
      \ 'commit'  : [ 'C' ],
      \ 'del'     : [ 'D' ],
      \ 'revert'  : [ 'R' ],
      \ 'shelve'  : [ 'S' ],
      \ 'uncommit': [ 'B' ],
      \ 'unshelve': [ 'U' ],
      \
      \ 'toggle_tag'  : [ '<Space>' ],
      \ 'tag_added'   : [ 'N' ],
      \ 'tag_deleted' : [ 'D' ],
      \ 'tag_modified': [ 'M' ],
      \ 'tag_renamed' : [ 'R' ],
      \ 'tag_unknown' : [ 'U' ],
      \ }

if exists('g:bzrstatus_mappings')
  call extend(s:bzrstatus_mappings, g:bzrstatus_mappings)
endif

let s:bzrstatus_nextline = '^\([-+R ][NDM][* ]\|[R?]  \|  \*\)'
let s:bzrstatus_matchline = s:bzrstatus_nextline.'\s\+\(.*\)$'

let s:bzrstatus_op_criterion =
      \ {
      \ 'add'     : 'unknown',
      \ 'commit'  : '!unknown',
      \ 'del'     : '!unknown && !deleted && !added',
      \ 'revert'  : 'modified || deleted || renamed || added',
      \ 'shelve'  : '!unknown',
      \ }

let s:bzrstatus_op_options =
      \ {
      \ 'commit'  : '--show-diff',
      \ 'log'     : '--line',
      \ 'missing' : '--line',
      \ }

if exists('g:bzrstatus_op_options')
  call extend(s:bzrstatus_op_options, g:bzrstatus_op_options)
endif

let s:bzrstatus_op_confirm =
      \ {
      \ 'revert'  : 1,
      \ 'unshelve': 1,
      \ }

let s:bzrstatus_op_update =
      \ {
      \ 'add'     : 1,
      \ 'commit'  : 1,
      \ 'del'     : 1,
      \ 'merge'   : 1,
      \ 'revert'  : 1,
      \ 'shelve'  : 1,
      \ 'switch'  : 1,
      \ 'uncommit': 1,
      \ 'unshelve': 1,
      \ }

if exists('g:bzrstatus_op_confirm')
  call extend(s:bzrstatus_op_confirm, g:bzrstatus_op_confirm)
endif

let s:bzrstatus_commands = []

for cmd in split(system(g:bzrstatus_bzr.' shell-complete'), "\n")
  let m = matchlist(cmd, '^\([_a-zA_Z][-_a-zA_Z0-9]*\)\(:.*\)\?$')
  if [] != m
    let s:bzrstatus_commands += [m[1]]
  endif
endfor

function! bzrstatus#tag_line(ln)

  if has_key(t:bzrstatus_tagged, a:ln)
    return
  endif

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

function! bzrstatus#untag_line(ln)

  if !has_key(t:bzrstatus_tagged, a:ln)
    return
  endif

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
      call bzrstatus#untag_line(ln)
    endfor
  endif

  let t:bzrstatus_tagged = {}

endfunction

function! bzrstatus:select_line(ln)

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

function! bzrstatus#unselect_line()

  if 0 == t:bzrstatus_selection
    return
  endif

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

  call bzrstatus#unselect_line()

  if a:clear_tagged
    call bzrstatus#clear_tagged()
  end

endfunction

function! bzrstatus#parse_entry_state(ln)

  if a:ln <= 2 || a:ln >= t:bzrstatus_msgline
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

  return [renamed, unknown, modified, deleted, added, old_entry, new_entry]

endfunction

function! bzrstatus#filter_entries(range, criterion)

  let files = []

  for ln in a:range

    let s = bzrstatus#parse_entry_state(ln)
    if [] == s
      continue
    endif

    let [renamed, unknown, modified, deleted, added, old_entry, new_entry] = s
    if !eval(a:criterion)
      continue
    endif

    let files += [new_entry]

  endfor

  return files

endfunction

function! bzrstatus#diff_open()

  let ln = line('.')

  let s = bzrstatus#parse_entry_state(ln)
  if [] == s
    return
  endif

  let [renamed, unknown, modified, deleted, added, old_entry, new_entry] = s

  let old_entry_fullpath = t:bzrstatus_tree.'/'.old_entry
  let new_entry_fullpath = t:bzrstatus_tree.'/'.new_entry

  call bzrstatus#clean_state(0)

  call bzrstatus:select_line(ln)

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
    setlocal buftype=nofile noswapfile
    " Get original version from Bazaar.
    let t:bzrstatus_tmpbuf = bufnr('')
    exe 'file [BZR] '.fnameescape(old_entry)
    redraw
    exe 'silent read !'.g:bzrstatus_bzr.' cat '.shellescape(old_entry_fullpath)
    exe 'normal 1Gdd'
  end

  if modified
    " Set filetype from original for correct syntax highlighting...
    let &ft = ft
    let &fenc = fenc
    diffthis
  elseif deleted
    " ...or try to detect it
    filetype detect
  endif

  exe bufwinnr(t:bzrstatus_buffer).' wincmd w'

endfunction

function! bzrstatus#exec_bzr(cmd, update)

  setlocal modifiable

  if line('$') > t:bzrstatus_msgline
    exe 'silent '.(t:bzrstatus_msgline + 1).',$delete'
  endif

  let cmd = g:bzrstatus_bzr.' '.a:cmd

  call append(t:bzrstatus_msgline, [cmd, ''])
  redraw

  let oldpwd = getcwd()
  exe 'lcd '.fnameescape(t:bzrstatus_tree)

  exe ':'.(t:bzrstatus_msgline + 2)
  let tf = tempname()
  if has('gui_running')
    let pre = ''
  else
    let pre = 'silent '
  endif
  exe pre.'!script -q -c '.shellescape(cmd).' '.tf
  exe 'read !col -pbx <'.tf
  exe (t:bzrstatus_msgline + 3).'g/^Script started/d'
  redraw!

  setlocal nomodifiable

  exe 'lcd '.fnameescape(oldpwd)

  if a:update
    call bzrstatus#update_buffer(0)
  endif

endfunction

function! bzrstatus#toggle_tag()

  let ln = line('.')
  if ln <= 2 || ln >= t:bzrstatus_msgline
    return
  endif

  if has_key(t:bzrstatus_tagged, ln)
    call bzrstatus#untag_line(ln)
  else
    call bzrstatus#tag_line(ln)
  endif

  call bzrstatus#next_entry(0, 1)

endfunction

function! bzrstatus#bzr_op(tagged, firstl, lastl, op)

  let criterion = get(s:bzrstatus_op_criterion, a:op, '')

  if '' != criterion

    if a:tagged
      let r = keys(t:bzrstatus_tagged)
    else
      let r = range(a:firstl, a:lastl)
    endif

    if [] == r
      return
    endif

    let files = bzrstatus#filter_entries(r, criterion)
    if [] == files
      return
    endif

  else

    let files = []

  endif

  let options = get(s:bzrstatus_op_options, a:op, '')
  let confirm = get(s:bzrstatus_op_confirm, a:op, 0)
  let update = get(s:bzrstatus_op_update, a:op, 0)

  let cmd = a:op

  if [] != files
    let cmd .= ' '.join(files, ' ')
  endif

  if confirm && 2 == confirm(cmd, "&Yes\n&No", 2)
    setlocal nomodifiable
    return
  endif

  let cmd = a:op

  if '' != options
    let cmd .= ' '.options
  endif

  if [] != files
    let cmd .= ' '.join(map(files, 'shellescape(v:val)'), ' ')
  endif

  call bzrstatus#exec_bzr(cmd, update)

endfunction

function! bzrstatus#add(tagged) range
  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'add')
endfunction

function! bzrstatus#commit(tagged) range
  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'commit')
endfunction
function! bzrstatus#del(tagged) range
  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'del')
endfunction

function! bzrstatus#revert(tagged) range
  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'revert')
endfunction

function! bzrstatus#shelve(tagged) range
  call bzrstatus#bzr_op(a:tagged, a:firstline, a:lastline, 'shelve')
endfunction

function! bzrstatus#uncommit()
  call bzrstatus#bzr_op(0, 0, 0, 'uncommit')
endfunction

function! bzrstatus#unshelve()
  call bzrstatus#bzr_op(0, 0, 0, 'unshelve')
endfunction

function! bzrstatus#info()
  call bzrstatus#bzr_op(0, 0, 0, 'info')
endfunction

function! bzrstatus#log()
  call bzrstatus#bzr_op(0, 0, 0, 'log')
endfunction

function! bzrstatus#missing()
  call bzrstatus#bzr_op(0, 0, 0, 'missing')
endfunction

function! bzrstatus#complete(arglead, cmdline, cursorpos)

  let args = split(a:cmdline[:a:cursorpos-1])

  if '' == a:arglead
    let argc = len(args) + 1
  else
    let argc = len(args)
  endif

  " call Decho('cmdline :'.a:cmdline)
  " call Decho('arglead :'.a:arglead)
  " call Decho('argc :'.argc)

  if 2 == argc

    " Complete command.

    let matches = []

    let re = '^\V'.escape(a:arglead, '\')

    for cmd in s:bzrstatus_commands
      if cmd =~ re
        let matches += [cmd]
      endif
    endfor

    return matches

  endif

  " Complete file path.

  let pattern = escape(a:arglead, '[]*?').'*'

  return split(glob(pattern), "\n")

endfunction

function! bzrstatus#exec(...)

  if [] == a:000
    return
  endif

  let [cmd; args] = a:000

  let update = get(s:bzrstatus_op_update, cmd, 0)

  let cmd .= ' '.join(args, ' ')

  call bzrstatus#exec_bzr(cmd, update)

endfunction

function! bzrstatus#get_entries(mode)

  if 'l' == a:mode
    let r = [line('.')]
  elseif 't' == a:mode
    let r = keys(t:bzrstatus_tagged)
  elseif 'v' == a:mode
    let r = range(line("'<"), line("'>"))
  else
    return []
  endif

  let entries = bzrstatus#filter_entries(r, '1')

  let s = ''

  for e in entries

    let es = shellescape(e)

    if es == "'".e."'"
      let s .= e.' '
    else
      let s .= es. ' '
    endif

  endfor

  return s

endfunction

function! bzrstatus#quit()

  call bzrstatus#clean_state(1)

  bwipeout

endfunction

function! bzrstatus#tag(criterion, set)

  let cursor_save = getpos('.')[1:3]

  :2

  while bzrstatus#next_entry(0, 0)

    let ln = line('.')

    let s = bzrstatus#parse_entry_state(ln)
    if [] == s
      continue
    endif

    let [renamed, unknown, modified, deleted, added, old_entry, new_entry] = s
    if eval(a:criterion)
      if a:set
        call bzrstatus#tag_line(ln)
      else
        call bzrstatus#untag_line(ln)
      endif
    endif

  endwhile

  call cursor(cursor_save)

endfunction

function! bzrstatus#next_entry(from_top, wrap)

  if a:from_top
    :2
  else
    exe 'normal $'
  endif

  if search(s:bzrstatus_nextline, 'eW', t:bzrstatus_msgline)
    return 1
  endif

  if a:wrap
    :2
    return search(s:bzrstatus_nextline, 'eW', t:bzrstatus_msgline)
  endif

  return 0

endfunction

function! bzrstatus#update_buffer(all)

  call bzrstatus#clean_state(1)

  let t:bzrstatus_tagged = {}

  setlocal modifiable

  if !a:all && exists('t:bzrstatus_msgline')
    exe 'silent 1,'.(t:bzrstatus_msgline - 1).'delete'
  else
    silent %delete
  endif

  let cmd = g:bzrstatus_bzr.' status -S -v '.shellescape(t:bzrstatus_path)
  call append(0, cmd)
  redraw

  :2
  exe 'silent read !'.cmd

  let l = line('.')
  call append(l, '')
  let t:bzrstatus_msgline = l + 1

  :2
  call bzrstatus#next_entry(1, 0)

  setlocal nomodifiable

endfunction

function! bzrstatus#update()
  call bzrstatus#update_buffer(1)
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
  setlocal buftype=nofile noswapfile ft=bzrstatus fenc=utf-8
  exe 'silent file '.fnameescape(t:bzrstatus_tree)

  let t:bzrstatus_buffer = bufnr('')

  if has('signs')
    sign define bzrstatus_sign_selection text=>> texthl=Search linehl=Search
    sign define bzrstatus_sign_selection_tag text=!> texthl=Search
    sign define bzrstatus_sign_tag text=!
    sign define bzrstatus_sign_start
    exe ':sign place 1 line=1 name=bzrstatus_sign_start buffer='.t:bzrstatus_buffer
  endif

  call bzrstatus#update_buffer(1)

  for name in [ 'quit', 'update', 'diff_open', 'info', 'log', 'missing', 'uncommit', 'unshelve', 'toggle_tag' ]
    for map in s:bzrstatus_mappings[name]
      exe 'nnoremap <silent> <buffer> '.map.' :call bzrstatus#'.name.'()<CR>'
    endfor
  endfor

  for name in [ 'add', 'commit', 'del', 'revert', 'shelve' ]
    for map in s:bzrstatus_mappings[name]
      exe 'nnoremap <silent> <buffer> '.map.' :call bzrstatus#'.name.'(0)<CR>'
      exe 'vnoremap <silent> <buffer> '.map.' :call bzrstatus#'.name.'(0)<CR>'
      exe 'noremap <silent> <buffer> ,'.map.' :call bzrstatus#'.name.'(1)<CR>'
    endfor
  endfor

  for name in [ 'added', 'deleted', 'modified', 'renamed', 'unknown' ]
    for map in s:bzrstatus_mappings['tag_'.name]
      exe 'nnoremap <silent> <buffer> ,<Space>'.toupper(map).' :call bzrstatus#tag("'.name.'", 1)<CR>'
      exe 'nnoremap <silent> <buffer> ,<Space>'.tolower(map).' :call bzrstatus#tag("'.name.'", 0)<CR>'
    endfor
  endfor

  for map in s:bzrstatus_mappings['exec']
    exe 'nnoremap <buffer> '.map.' :let t:bzrstatus_mode="l"<CR>:BzrStatusExec '
    exe 'vnoremap <buffer> '.map.' v:let t:bzrstatus_mode="v"<CR>:BzrStatusExec '
  endfor

  cnoremap <buffer> <C-R><C-E> <C-R>=bzrstatus#get_entries(t:bzrstatus_mode)<CR>
  cnoremap <buffer> <C-R><C-T> <C-R>=bzrstatus#get_entries('t')<CR>

endfunction

command! -nargs=* -complete=customlist,bzrstatus#complete BzrStatusExec call bzrstatus#exec(<f-args>)

