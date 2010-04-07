
if exists('g:loaded_tags_utils_autoload') || &cp
 finish
endif
let g:loaded_tags_utils_autoload = 1

" Compare QuickFix List entries based on filenames,
" using bufname(bufnr) when filename is not set.
function s:QFListCompareFnames(e1, e2)
  let f1 = get(a:e1, 'filename', bufname(a:e1.bufnr))
  let f2 = get(a:e2, 'filename', bufname(a:e2.bufnr))
  return f1 == f2 ? 0 : f1 > f2 ? 1 : -1
endfunction

" Find a file, first using findfile(), and cscope "find file" if connection is
" available. All matches are collected in a new quickfix list. If goto_line is
" not 0, then jump to line[:col] if its present (:xxx after the filename). If
" file_expr is not empty and goto_line is >1, then the :xxx directive must be
" present. If goto_line is >2, delete old buffer.
function! tags_utils#TagsFindFile(file_expr, goto_line)

  let line = 1
  let col = 1

  let bufname = bufname('%')

  if empty(a:file_expr)

    " No file_expr passed as argument, use filename on the current cursor
    " position.

    let fname = expand('<cfile>')

    if a:goto_line

      let line = getline('.')[col('.') - 1 : ]
      let match = matchlist(line, '^\f\+:\(\d\+\)\(:\(\d\+\)\)\?')

      if !empty(match)
        let line = str2nr(match[1])
        if 3 < len(match)
          let col = str2nr(match[3])
        endif
      endif

    endif

  else

    " Use file_expr argument.

    let fname = a:file_expr

    if a:goto_line

      let match = matchlist(fname, '^\(\f\+\):\(\d\+\)\(:\(\d\+\)\)\?$')

      if empty(match)
        if a:goto_line > 1
          return
        end
      else
        let fname = match[1]
        let line = str2nr(match[2])
        if 4 < len(match)
          let col = str2nr(match[4])
        endif
      endif

    endif

  endif

  let oldqflist = getqflist()

  let matches = findfile(fname, '', -1)

  if cscope_connection()
    silent! exe ':csc f f '.fname
  endif

  let qflist = getqflist()
  if qflist == oldqflist
    if 0 == len(matches)
      return
    end
    let qflist = []
    let qflist_action = ' '
  else
    for qfe in qflist
      let qfe.lnum = line
      let qfe.col = col
    endfor
    let qflist_action = 'r'
  endif

  for m in matches
    call insert(qflist, {
          \ 'bufnr': 0, 'filename': m,
          \ 'lnum': line, 'col': col, 'vcol': 0,
          \ 'valid': 1, 'nr': -1,
          \ 'type': '', 'pattern': '',
          \ 'text': '<<<unknown>>>'
          \ })
  endfor

  if 0 == len(qflist)
    return
  endif

  " Sort based on filenames.
  call sort(qflist, 'QFListCompareFnames')

  " And remove dupplicates (keeping valid buffer numbers).
  let n = 1
  while n < len(qflist)
    let e1 = qflist[n - 1]
    let e2 = qflist[n]
    if 0 == QFListCompare(e1, e2)
      if 0 == e1.bufnr
        let e1.bufnr = e2.bufnr
      endif
      call remove(qflist, n)
    else
      let n += 1
    endif
  endwhile

  call setqflist(qflist, qflist_action)

  " Jump to first entry.
  cc 1

endfunction

function! tags_utils#TagsFindInclude(reg, tag_pattern)

  let tags = taglist(a:tag_pattern)

  if empty(tags)
    return
  end

  let includes = []

  for tag in tags
    let include = tag['filename']
    if include !~ '\.hh\?$'
      continue
    endif
    if empty(a:reg)
      echo include
      continue
    endif
    let include = substitute(include, '.*[\\\/]', '', '')
    call setreg(a:reg, '#include "'.include."\"\n")
    return
  endfor

endfunction

" Rename all reference to a symbol using cscope. Based on:
" http://www.vim.org/scripts/script.php?script_id=2164
function! tags_utils#TagsRename()
  " store old buffer and restore later
  let stored_buffer = bufnr("%")

  " start refactoring
  let old_name = expand("<cword>")
  let new_name = input("new name: ",old_name)

  let cscope_out = system(&cscopeprg.' -L -d -F cscope.out -0 ' . old_name)
  let cscope_out_list = split(cscope_out, '\n')

  for cscope_line in cscope_out_list
    let cscope_line_split = split(cscope_line, ' ')
    let subs_file = cscope_line_split[0]
    let subs_lnr = cscope_line_split[2]
    let subs_buffer = bufnr(subs_file)

    if subs_buffer == -1
      exe 'edit '.subs_file
      let do_close = 1
      let subs_buffer = bufnr(subs_file)
    else
      let do_close = 0
    endif

    if subs_buffer != -1
      exe 'buffer '.subs_buffer
      exe subs_lnr.','.subs_lnr.'s/\<'.old_name.'\>/'.new_name.'/gc'
      exe 'write'
      if do_close == 1
        exe 'bd'
      endif
    endif
  endfor
  exe 'buffer '.stored_buffer
endfunction

